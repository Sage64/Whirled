wanna use my shit?
add myclasses to your classpaths

Full avatar for reference:
https://github.com/Sage64/Whirled/blob/master/myclasses/deltarune/HolyWaterBody.as

Avatars only need 1 scene and 3 frames, you can store multiple in the same flash file to make use of common sprites/etc and export using Test Scene to check it works and publish a .swf to the .fla folder.

I've rebound Test Movie/Test Scene to F5/F6 for convenience

Keyframe 3 code: GMControl.Loop();

<img width="918" height="538" alt="image" src="https://github.com/user-attachments/assets/8c5b0685-a27c-4790-9e6b-832e2c5ed214" />




multiple characters as part of the same avatar is still wip

third argument of "AddBody" is the body class constructor function

"Sprites" are symbols, with each keyframe being a sub-image.

Group common sprites by placing them anywhere within a symbol that is exported for actionscript, and label each sprite within it as neccessary.
Disable "Export in frame 1" to prevent unneccessary images inflating the file size!

That symbol must be added in the main event to the avatar using "GMControl.AddSprites( <class_name> );"
any amount of these can be added this way

Currently, any sprite itself that needs to be drawn multiple times must also be exported for actionscript, but this class name cannot be the same as its sprite name. Any workaround for this is fine as the classname itself isnt important, I choose to stick a "c_" infront of it
e.g spr_watercooler_parts -> c_spr_watercooler_parts

<img width="1292" height="825" alt="image" src="https://github.com/user-attachments/assets/134fd21e-d728-4325-8071-621116a15936" />
<img width="851" height="429" alt="image" src="https://github.com/user-attachments/assets/bdc6fd65-ab73-4230-87df-46777210ade6" />
