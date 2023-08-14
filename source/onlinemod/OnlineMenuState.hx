package onlinemod;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
#if desktop
import Discord.DiscordClient;
#end

class OnlineMenuState extends MusicBeatState
{
  var curSelected:Int = 0;

  var options:Array<String> = ["play online", "host a server", "play offline"];
  var descriptions:Array<String> = ["Play online with other people.", "Host your own Multi.hx server!",
  "Play songs that have been downloaded during online games."];

  var descriptionText:FlxText;
  var grpControls:FlxTypedGroup<Alphabet>;

  override function create()
  {
    var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuDesat"));
    bg.color = 0xFFFF6E6E;
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

    grpControls = new FlxTypedGroup<Alphabet>();
		add(grpControls);

		for (i in 0...options.length)
		{
			var controlLabel:Alphabet = new Alphabet(0, (70 * i) + 30, options[i], true, false);
			controlLabel.isMenuItem = true;
			controlLabel.targetY = i;
      if (i != 0)
        controlLabel.alpha = 0.6;
			grpControls.add(controlLabel);
		}


    descriptionText = new FlxText(5, FlxG.height - 18, 0, descriptions[0], 12);
		descriptionText.scrollFactor.set();
		descriptionText.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(descriptionText);


    FlxG.mouse.visible = false;
    FlxG.autoPause = true;


    super.create();
  }

  override function update(elapsed:Float)
  {
    super.update(elapsed);

    if (controls.BACK)
    {
      FlxG.switchState(new MainMenuState());
    }

    if (controls.UP_P)
      changeSelection(-1);
    if (controls.DOWN_P)
      changeSelection(1);

    if (controls.ACCEPT)
    {
      switch (curSelected)
      {
        case 0: // Play online
          FlxG.switchState(new OnlinePlayMenuState());
        case 1: // host
          FlxG.switchState(new OnlineHostMenu());            
        case 2: // offline
          FlxG.switchState(new OfflineMenuState());
      }
    }
  }

  function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound("scrollMenu"), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = grpControls.length - 1;
		if (curSelected >= grpControls.length)
			curSelected = 0;


    descriptionText.text = descriptions[curSelected];


		var bullShit:Int = 0;

		for (item in grpControls.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;

			if (item.targetY == 0)
			{
				item.alpha = 1;
			}
		}
	}
}
