package onlinemod;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.ui.FlxUIButton;
import flixel.addons.ui.FlxInputText;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxAxes;

class OnlineHostMenu extends MusicBeatState
{
  var errorText:FlxText;
  var portField:FlxInputText;
  var pwdField:FlxInputText;

  override function create()
  {
    var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
    bg.color = 0xFFea71fd;
    add(bg);

		var mf:FlxSprite = new FlxSprite(-80).loadGraphic('assets/images/mainmenu/menuframes.png');
		mf.scrollFactor.x = 0;
		mf.scrollFactor.y = 0;
		mf.setGraphicSize(Std.int(mf.width * 1));
		mf.updateHitbox();
		mf.screenCenter();
		mf.antialiasing = true;
		add(mf);

		var t1:FlxSprite = new FlxSprite(-80).loadGraphic('assets/images/mainmenu/triangles1.png');
		t1.scrollFactor.x = 0;
		t1.scrollFactor.y = 0;
		t1.setGraphicSize(Std.int(t1.width * 1));
		t1.updateHitbox();
		t1.screenCenter();
		t1.antialiasing = true;
		add(t1);

		var t2:FlxSprite = new FlxSprite(-80).loadGraphic('assets/images/mainmenu/triangles2.png');
		t2.scrollFactor.x = 0;
		t2.scrollFactor.y = 0;
		t2.setGraphicSize(Std.int(t2.width * 1));
		t2.updateHitbox();
		t2.screenCenter();
		t2.antialiasing = true;
		add(t2);

		var t3:FlxSprite = new FlxSprite(-80).loadGraphic('assets/images/mainmenu/triangles3.png');
		t3.scrollFactor.x = 0;
		t3.scrollFactor.y = 0;
		t3.setGraphicSize(Std.int(t3.width * 1));
		t3.updateHitbox();
		t3.screenCenter();
		t3.antialiasing = true;
		add(t3);

		var t4:FlxSprite = new FlxSprite(-80).loadGraphic('assets/images/mainmenu/triangles4.png');
		t4.scrollFactor.x = 0;
		t4.scrollFactor.y = 0;
		t4.setGraphicSize(Std.int(t4.width * 1));
		t4.updateHitbox();
		t4.screenCenter();
		t4.antialiasing = true;
		add(t4);

    var topText = new FlxText(0, FlxG.height * 0.15, "Host server");
    topText.setFormat(Paths.font("vcr.ttf"), 64, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    topText.screenCenter(FlxAxes.X);
    add(topText);


    errorText = new FlxText(0, FlxG.height * 0.275, FlxG.width, "");
    errorText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER);
    add(errorText);


    var portText:FlxText = new FlxText(FlxG.width/2 - 350, FlxG.height * 0.4 - 40, "Port:");
    portText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    add(portText);

		portField = new FlxInputText(0, FlxG.height * 0.4, 700, 32);
		portField.setFormat(32, FlxColor.BLACK, CENTER);
		portField.screenCenter(FlxAxes.X);
		portField.customFilterPattern = ~/[^0-9]/;
		portField.maxLength = 6;
    portField.hasFocus = true;
		add(portField);


    var pwdText:FlxText = new FlxText(FlxG.width/2 - 350, FlxG.height * 0.6 - 40, "Password:");
    pwdText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    add(pwdText);

		pwdField = new FlxInputText(0, FlxG.height * 0.6, 700, 32);
		pwdField.setFormat(32, FlxColor.BLACK, CENTER);
		pwdField.screenCenter(FlxAxes.X);
    pwdField.passwordMode = false;
		add(pwdField);


    var hostButton = new FlxUIButton(0, FlxG.height * 0.75, "Host", () -> {
      SetErrorText("This is WIP");
    });
		hostButton.setLabelFormat(32, FlxColor.BLACK, CENTER);
		hostButton.resize(300, FlxG.height * 0.1);
		hostButton.screenCenter(FlxAxes.X);
		add(hostButton);


    FlxG.mouse.visible = true;


    super.create();
  }

  override function update(elapsed:Float)
  {
    if (!(portField.hasFocus || pwdField.hasFocus))
    {
      OnlinePlayMenuState.SetVolumeControls(true);
      if (controls.BACK)
      {
        FlxG.switchState(new OnlineMenuState());
      }
    }
    else
    {
      OnlinePlayMenuState.SetVolumeControls(false);
    }

    super.update(elapsed);
  }

  function SetErrorText(text:String, color:FlxColor=FlxColor.RED)
  {
    errorText.text = text;
    errorText.setFormat(32, color);
    errorText.setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
  }
}
