module Skel

=begin
This module contains two classes (Bone and Skeleton) that enable skeletal animation in SketchUp. 

The following methods are all you need to know:
Skeleton.new - Create a new Skeleton with a given name
Skeleton.add_root - Create a Bone to represent the root of the Skeleton
Bone.add_child - Create a Bone to be added as a child
Bone.add_keyframe - Tell the Bone to rotate around a given axis in a given time

The Skeleton.add_root and Bone.add_child methods both create and return a Bone object. Both methods have three parameters (one required, two optional):
comp (required) - the ComponentDefinition that defines the Bone's appearance
trans (optional) - the Transformation needed to place the Bone in the model
joint (optional) - the point around which the Bone rotates ([0, 0, 0] by default)

The Skel module is released under the Apache 2.0 License, which means it can be used for open-source or proprietary development. If you have any questions, please write to mattscar@gmail.com.
=end


# The bone class represents a single moveable part in the animation. Bones have a parent-child relationship, in which the parent bone
# controls how its children move. Each bone also stores a joint that defines its origin of rotation.
class Bone

   attr_accessor :comp, :trans, :joint, :children, :track

   # Create a new Bone
   def initialize comp, trans=Geom::Transformation.new, joint=[0,0,0]
   
      # Sets the ComponentDefinition for the Bone
      @comp = comp
      
      # The Transformation that sets the Bone's initial position
      @trans = trans
      
      # The point around which the Bone rotates
      @joint = joint
      
      # Children of the Bone - Bones that depend on this Bone for position
      @children = Array.new
      
      # Array of rotations over time that determine the Bone's rotation
      @track = Array.new
   end
   
   # Create a new Bone and add it as child of this Bone
   def add_bone comp, trans=Geom::Transformation.new, joint=[0,0,0]
      bone = Bone.new comp, trans, joint
      @children << bone
      bone
   end
   
   # Create a new timed rotation
   def add_keyframe axis, angle, time

      # Add the keyframe to the track
      @track << [axis, angle, time]
   end
end

# A Skeleton object represents the overall animated structure - comprises one or more Bones
class Skeleton

   # Create a new skeletal hierarchy of bones
   def initialize name, interval=0.1
   
      # Time between frames in the animation
      @interval = interval
      
      # Overall ComponentDefinition for the Skeleton
      @comp = Sketchup.active_model.definitions.add name
      @ents = @comp.entities
      
      # Time for the overall animation
      @max_period = 0
      
      # Timed movements for the overall skeleton
      @track = Array.new
   end

   # Create a new timed movement (Transformation) that applies to the entire skeleton
   def add_keyframe t, time
   
      # Set the transformation per interval
      t = Geom::Transformation.interpolate Geom::Transformation.new, t, (@interval/time)
      @track << [t, time]
      if time > @max_period
         @max_period = time
      end
   end
   
   # Animate the skeleton. This recursively animates the skeleton and bones depending on their
   # keyframes. If there are no keyframes, each ComponentInstance is created and positioned statically.
   def animate time=0
         
      # Create bone instances, starting with the root
      create_instance @root_bone
      
      # Create the top-level skeleton instance
      Sketchup.active_model.entities.add_instance @comp, Geom::Transformation.new

      # Start the timer
      @clk = 0
      timer = UI.start_timer(@interval, true) {

         # Check for completion         
         if @clk + 0.001 > @max_period
         
         #@max_period
            UI.stop_timer timer
         end

         # Increment the clock
         @clk += @interval
         
         # Start animation - skeleton's keyframe first
         skeleton_transform = Geom::Transformation.new
         for keyframe in @track
            if @clk <= keyframe[1]
               skeleton_transform = keyframe[0] * skeleton_transform
               break
            end
         end
                  
         # Animate the bones
         animate_kernel @root_bone, skeleton_transform
      }
   end

   # This is the recursive method that actually performs the animation
   def animate_kernel bone, t
   
      # Transform the joint
      bone.joint = bone.joint.transform! t
   
      # Create the child's animation transformation
      for keyframe in bone.track
         if @clk <= keyframe[2]
            child_t = Geom::Transformation.rotation bone.joint, keyframe[0], keyframe[1]
            t = child_t * t
            break
         end
      end
      
      # Transform the child
      bone.comp.transform! t
      
      # Animate child bones
      for child in bone.children
         animate_kernel child, t
      end
   end
   
   # This creates and positions the bones within the design window
   def create_instance bone
   
      # Transform the bone component and its joint
      bone.comp = @ents.add_instance bone.comp, bone.trans
      bone.joint.transform! bone.trans
      
      # Divide each keyframe angle by the rotation time
      # This sets the degrees rotated during each interval
      prev_time = 0
      for keyframe in bone.track
         keyframe[1] = (keyframe[1] * @interval)/(keyframe[2] - prev_time)
         prev_time = keyframe[2]
      end
      
      # Update the maximum period if necessary
      if bone.track.length != 0 && bone.track.last[2] > @max_period
         @max_period = bone.track.last[2]
      end

      # Create instances of children
      for b in bone.children
         create_instance b
      end
   end
   
   # Sets the root bone in the hierarchy - this bone controls the movement of all its children
   def set_root comp, trans=Geom::Transformation.new, joint=[0,0,0]
      raise "First set_root argument must be a ComponentDefinition" unless comp.kind_of? Sketchup::ComponentDefinition
      @root_bone = Bone.new comp, trans, joint
   end
end

end