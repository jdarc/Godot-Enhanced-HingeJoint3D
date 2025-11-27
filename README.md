
# Enhanced HingeJoint3D for Godot 4.5+

Augments Godot's HingeJoint3D with the ability to query the current angle of the joint.

## Features

There have been a few requests to expose the HingeJoint3D current angle as a property or method.

The Jolt physics engine supports this on the HingeConstraint via `HingeConstraint::GetCurrentAngle()`

I inspected the Godot source and ported the code that enables Jolt to perform the necessary calculations. This addon is the result of that investigation which I hope will prove useful to others.

I have check the values this script returns against a custom Godot build that integrated the changes from the PR mentioned below.

However, this is not an ideal solution and hopefully any of the following paths are taken soon:

- Merge this PR: [Add the ability to get the angle of a hinge joint.](https://github.com/godotengine/godot/pull/110473)
- Implement a generic solution `get_angle()` or property that works across any physics engine, Jolt, Godot, Rapier, etc.

## Example Project

I have put together a small demo scene in the example folder. It contains an articulated robot arm based on [Robot Arm](https://sketchfab.com/3d-models/robot-arm-blender-mechanically-rigged-6fa4d326c5314b71be3e6869ce7b9c9f) The UI enables the specification of a target angle to move towards from the current angle for each component.

In a ironic twist of events, it *seems* to work better with the Godot Physics engine than it does with Jolt. It is very likely I have incorrectly configure something somewhere and any help in figuring out what would be appreciated.

Having said that there are some major differences between the two physics engines that I wasn't aware of such as: [HingeJoint3D angular limits are inverted when using Jolt physics.](https://github.com/godotengine/godot/issues/112362)

## Installation

1. Download or clone this repository to your local machine.
2. Copy the `enhancedhingejoint3d` folder into the `addons` directory of your Godot project.
3. In the Godot editor, navigate to `Project → Project Settings → Plugins` and enable the `Enhanced HingeJoint3D` plugin.

## Usage

1. Use this joint variant as you would the built-in HingeJoint3D.
2. Once the joint is configured, call `rebuild()` once at runtime.
3. The simply call the `current_angle` property to retrieve the current angle in radians.
4. If you change the joint's configuration you must call `rebuild` once again.

## License

This project is licensed under the MIT License - see the [LICENSE](addons/enhancedhingejoint3d/LICENSE.txt) file for details.

## Support

If you encounter any issues or have suggestions, please [open an issue](https://github.com/jdarc/Godot-Enhanced-HingeJoint3D/issues) or submit a pull request.
