require "skel_animation.rb"

model = Sketchup.active_model

# Create component for upper arm
upper_comp = model.definitions.add "Upper Arm"
face = upper_comp.entities.add_face [-0.5,-0.5,0], 
   [0.5,-0.5,0], [0.5,0.5,0], [-0.5,0.5,0]
face.pushpull -3

# Create component for lower arm
lower_comp = model.definitions.add "Lower Arm"
face = lower_comp.entities.add_face [0,-0.5,-0.5], 
   [2,-0.5,-0.5], [2,0.5,-0.5], [0,0.5,-0.5]
face.pushpull 1

# Create two Transformations
upper_t = Geom::Transformation.translation [0,0,2]
lower_t = Geom::Transformation.rotation [0,0,0], [0,1,0], 17.degrees

# Create the Skeleton and two Bones
arm_skeleton = Skel::Skeleton.new "Arm"
upper_bone = arm_skeleton.set_root upper_comp, upper_t, [0,0,3]
lower_bone = upper_bone.add_bone lower_comp, upper_t * lower_t
arm_skeleton.animate