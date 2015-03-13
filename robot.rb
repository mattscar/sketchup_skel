require "skel_animation.rb"

model = Sketchup.active_model

# Dimensions
head_radius = 1.5
body_radius = 1.5
body_height = 4.5

# Create torso component
torso_comp = model.definitions.add "Torso"
path = torso_comp.entities.add_circle [0,0,0], [0,0,1], body_radius
body = torso_comp.entities.add_face [0,0,0], [0,0,body_height], [0,2.5,body_height], [0,1.5,0]
body.followme path

# Create head component
head_comp = model.definitions.add "Head"
path = head_comp.entities.add_circle [0,0,0], [0,0,1], body_radius
circle = head_comp.entities.add_circle [0,0,0], [0,1,0], head_radius
circle_face = head_comp.entities.add_face circle
circle_face.followme path

# Create upper arm component
upper_arm_comp = model.definitions.add "Upper Arm"
face = upper_arm_comp.entities.add_face [-0.5,-0.5,0], 
   [0.5,-0.5,0], [0.5,0.5,0], [-0.5,0.5,0]
face.pushpull -3

# Create lower arm component
lower_arm_comp = model.definitions.add "Lower Arm"
face = lower_arm_comp.entities.add_face [0,-0.5,-0.5], 
   [2,-0.5,-0.5], [2,0.5,-0.5], [0,0.5,-0.5]
face.pushpull 1

# Create upper leg component
upper_leg_comp = model.definitions.add "Upper Leg"
circle = upper_leg_comp.entities.add_circle [0,0,0], [0,0,1], 1
circle_face = upper_leg_comp.entities.add_face circle
circle_face.pushpull 3.5

# Create lower leg component
lower_leg_comp = model.definitions.add "Lower Leg"
circle = lower_leg_comp.entities.add_circle [0,0,0], [0,0,1], 0.75
circle_face = lower_leg_comp.entities.add_face circle
circle_face.pushpull 3
foot = lower_leg_comp.entities.add_circle [0.75,0,-2.75], [0,0,1], 0.8
foot_face = lower_leg_comp.entities.add_face foot
foot_face.pushpull -0.25

# Create skeleton, root, and head bones
robot_skeleton = Skel::Skeleton.new "Robot"
torso = robot_skeleton.set_root torso_comp, [0,0,0]
head = torso.add_bone head_comp, [0, 0, body_height + head_radius]

# Create upper arm bones
upper_arm_trans_r = Geom::Transformation.translation([0.0, body_radius+2, 1.75]) *
   Geom::Transformation.rotation([0,0,0], [1,0,0], 40.degrees)
upper_arm_trans_l = Geom::Transformation.translation([0.0, -(body_radius+2), 1.75]) *
   Geom::Transformation.rotation([0,0,0], [1,0,0], -40.degrees)
upper_arm_r = torso.add_bone upper_arm_comp, upper_arm_trans_r, [0,0,3]
upper_arm_l = torso.add_bone upper_arm_comp, upper_arm_trans_l, [0,0,3]

# Create lower arm bones
lower_arm_trans_r = upper_arm_trans_r * 
   Geom::Transformation.rotation([0,0,0], [0, 1, 0], 17.degrees)
lower_arm_trans_l = upper_arm_trans_l * 
   Geom::Transformation.rotation([0,0,0], [0, 1, 0], 17.degrees)
lower_arm_r = upper_arm_r.add_bone lower_arm_comp, lower_arm_trans_r
lower_arm_l = upper_arm_l.add_bone lower_arm_comp, lower_arm_trans_l

# Create upper leg bones
upper_leg_trans_r = Geom::Transformation.translation([0,0.5,0.25]) * 
   Geom::Transformation.rotation([0,0,0], [1,0,0], 25.degrees)
upper_leg_trans_l = Geom::Transformation.translation([0,-0.5,0.25]) * 
   Geom::Transformation.rotation([0,0,0], [1,0,0], -25.degrees)
upper_leg_r = torso.add_bone upper_leg_comp, upper_leg_trans_r
upper_leg_l = torso.add_bone upper_leg_comp, upper_leg_trans_l

# Create lower leg bones
lower_leg_trans_r = Geom::Transformation.rotation([0,0,0], [1,0,0], 25.degrees) *
   Geom::Transformation.translation([0,0.5,-3]) *
   Geom::Transformation.rotation([0,0,0], [1,0,0], -15.degrees)
lower_leg_trans_l = Geom::Transformation.rotation([0,0,0], [1,0,0], -25.degrees) *
   Geom::Transformation.translation([0,-0.5,-3]) *
   Geom::Transformation.rotation([0,0,0], [1,0,0], 15.degrees)
lower_leg_r = upper_leg_r.add_bone lower_leg_comp, lower_leg_trans_r
lower_leg_l = upper_leg_l.add_bone lower_leg_comp, lower_leg_trans_l

# Animate skeleton
forward = Geom::Transformation.translation [5,0,0]
backward = Geom::Transformation.translation [-5,0,0]
robot_skeleton.add_keyframe forward, 5
robot_skeleton.add_keyframe backward, 10
robot_skeleton.add_keyframe forward, 15

# Animate torso
torso.add_keyframe [0, 0, 1], -60.degrees, 5
torso.add_keyframe [0, 0, 1], 120.degrees, 10
torso.add_keyframe [0, 0, 1], -60.degrees, 15
 
# Animate upper arms
upper_arm_r.add_keyframe [1, 1, 0], 30.degrees, 5
upper_arm_r.add_keyframe [1, 1, 0], -60.degrees, 10
upper_arm_r.add_keyframe [1, 1, 0], 30.degrees, 15
upper_arm_l.add_keyframe [1, 1, 0], -30.degrees, 5
upper_arm_l.add_keyframe [1, 1, 0], 60.degrees, 10
upper_arm_l.add_keyframe [1, 1, 0], -30.degrees, 15

# Animate lower arms
lower_arm_r.add_keyframe [0, 1, 0], 40.degrees, 5
lower_arm_r.add_keyframe [0, 1, 0], -80.degrees, 10
lower_arm_r.add_keyframe [0, 1, 0], 40.degrees, 15
lower_arm_l.add_keyframe [0, 1, 0], -40.degrees, 5
lower_arm_l.add_keyframe [0, 1, 0], 80.degrees, 10
lower_arm_l.add_keyframe [0, 1, 0], -40.degrees, 15

# Animate upper legs
upper_leg_r.add_keyframe [0, 1, 0], 30.degrees, 5
upper_leg_r.add_keyframe [0, 1, 0], -60.degrees, 10
upper_leg_r.add_keyframe [0, 1, 0], 30.degrees, 15
upper_leg_l.add_keyframe [0, 1, 0], -30.degrees, 5
upper_leg_l.add_keyframe [0, 1, 0], 60.degrees, 10
upper_leg_l.add_keyframe [0, 1, 0], -30.degrees, 15

# Animate lower legs
lower_leg_r.add_keyframe [0, 1, 0], 50.degrees, 5
lower_leg_r.add_keyframe [0, 1, 0], -100.degrees, 10
lower_leg_r.add_keyframe [0, 1, 0], 50.degrees, 15
lower_leg_l.add_keyframe [0, 1, 0], -50.degrees, 5
lower_leg_l.add_keyframe [0, 1, 0], 100.degrees, 10
lower_leg_l.add_keyframe [0, 1, 0], -50.degrees, 15

# Animate
robot_skeleton.animate

