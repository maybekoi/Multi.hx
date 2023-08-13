package onlinemod;

import flixel.FlxG;
import flixel.FlxBasic;
import flixel.FlxSprite;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import flixel.util.FlxAxes;
import flixel.FlxSubState;
import flixel.tweens.FlxTween;
import flixel.system.FlxSound;
import flash.media.Sound;

import Section.SwagSection;

#if windows
import Discord.DiscordClient;
#end

class OnlinePlayState extends PlayState
{
  var clients:Map<Int, String> = [];
  public static var clientScores:Map<Int, Int> = [];
  var clientTexts:Map<Int, Int> = [];
  var clientsGroup:FlxTypedGroup<FlxText>;

  var clientCount:Int = 1;

  var waitingBg:FlxSprite;
  var waitingText:FlxText;

  var customSong:Bool;
  var loadedVoices:FlxSound;
  var loadedInst:Sound;

  var ready:Bool = false;

  var inPause:Bool = false;

  var originalSafeFrames:Int = FlxG.save.data.frames;

  public function new(customSong:Bool, voices:FlxSound, inst:Sound)
  {
    super();

    this.customSong = customSong;
    this.loadedVoices = voices;
    this.loadedInst = inst;
  }

  override function create()
  {
    if (customSong){
      PlayState.SONG.player1 = 'bf';
      PlayState.SONG.player2 = 'dad';
    }

    super.create();

		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("Rapping against someone online...", null);
		#end

    clients = OnlineLobbyState.clients.copy();
    clientScores = [];
    clientsGroup = new FlxTypedGroup<FlxText>();

    // Add the score UI for other players
    for (i in OnlineLobbyState.clients.keys())
    {
      clientScores[i] = 0;
      clientCount++;

      var scoreY:Float;
      if (FlxG.save.data.downscroll)
        scoreY = 10 + 28*(clientsGroup.length);
      else
        scoreY = healthBarBG.y + 30 - 28*(clientsGroup.length + 1);

      var text = new FlxText(10, scoreY, '${OnlineLobbyState.clients[i]}: 0');
      text.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
      text.scrollFactor.set(0, 0);
      clientTexts[i] = clientsGroup.length;
      clientsGroup.add(text);
      text.cameras = [camHUD];
    }
    add(clientsGroup);


    // Add XieneDev watermark
    var xieneDevWatermark:FlxText = new FlxText(-4, FlxG.height * 0.9 + 50, FlxG.width, "Multi.hx BETA", 16);
		xieneDevWatermark.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT, FlxTextBorderStyle.OUTLINE,FlxColor.BLACK);
		xieneDevWatermark.scrollFactor.set();
		add(xieneDevWatermark);
    


    // The screen with 'Waiting for players (1/4)' stuff
    waitingBg = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
    waitingBg.alpha = 0.5;
    add(waitingBg);
    waitingBg.cameras = [camHUD];

    waitingText = new FlxText(0, 0, 'Waiting for players (?/${clientCount})');
    waitingText.setFormat(Paths.font("vcr.ttf"), 64, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    waitingText.screenCenter(FlxAxes.XY);
    add(waitingText);
    waitingText.cameras = [camHUD];


    // Remove healthbar
    if (FlxG.save.data.downscroll)
      scoreTxt.y = 10;
    remove(healthBarBG);
    remove(healthBar);
    remove(iconP1);
    remove(iconP2);


    OnlinePlayMenuState.receiver.HandleData = HandleData;
    new FlxTimer().start(transIn.duration, (timer:FlxTimer) -> Sender.SendPacket(Packets.GAME_READY, [], OnlinePlayMenuState.socket));


    FlxG.mouse.visible = false;
    FlxG.autoPause = false;
  }

  override function startCountdown()
  {
    if (!ready)
      return;

    super.startCountdown();
  }

  override function startSong()
  {
    FlxG.sound.playMusic(loadedInst, 1, false);

    paused = true; // Setting 'paused' to true makes it so 'super.startSong()' doesn't try to load the Inst track
    super.startSong();
    paused = false;
  }

  override function generateSong(dataPath:String)
  {
    // I have to code the entire code over so that I can remove the offset thing
    var songData = PlayState.SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (PlayState.SONG.needsVoices)
			vocals = loadedVoices;
		else
			vocals = new FlxSound();

		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		// Per song offset check
		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0] + FlxG.save.data.offset;
				if (daStrumTime < 0)
					daStrumTime = 0;
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = section.mustHitSection;

				if (songNotes[1] > 3)
				{
					gottaHitNote = !section.mustHitSection;
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength = susLength / Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
				else
				{
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
  }

  override function popUpScore(strumtime:Float, daNote:Note):Void
  {
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";

		var isSick:Bool = true;

		if (noteDiff > Conductor.safeZoneOffset * 0.9)
		{
			daRating = 'shit';
			score = 50;
			isSick = false;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'bad';
			score = 100;
			isSick = false;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		{
			daRating = 'good';
			score = 200;
			isSick = false;
		}

		if (isSick)
		{
			var noteSplash:NoteSplash = new NoteSplash(daNote.x, daNote.y, daNote.noteData);
			add(noteSplash);

			noteSplash.cameras = [camHUD];			
		}

		songScore += score;

		/* if (combo > 60)
				daRating = 'sick';
			else if (combo > 12)
				daRating = 'good'
			else if (combo > 4)
				daRating = 'bad';
		 */

		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		rating.loadGraphic(Paths.loadImage(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.y += 200;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		comboSpr.updateHitbox();
		rating.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);

		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.loadImage(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80 + 200;

			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 10 || combo == 0)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();

				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;

    SendScore();
  }

  override function noteMiss(direction:Int = 1, daNote:Note):Void
  {
    super.noteMiss(direction, daNote);

    SendScore();
  }

  override function resyncVocals()
  {
    // So you can't play the game while being paused
    if (inPause)
      return;

    super.resyncVocals();
  }

  override function endSong():Void
  {
    clients[-1] = OnlineNickState.nickname;
    clientScores[-1] = songScore;

    canPause = false;
    FlxG.sound.music.onComplete = null;
    FlxG.sound.music.pause();
		vocals.volume = 0;
    vocals.pause();

    Sender.SendPacket(Packets.GAME_END, [], OnlinePlayMenuState.socket);

    FlxG.switchState(new OnlineResultState(clients));
  }

  override function keyShit()
  {
    if (inPause)
      return;

    super.keyShit();
  }

  override function openSubState(SubState:FlxSubState)
  {
    if (Type.getClass(SubState) == PauseSubState)
    {
      var realPaused:Bool = paused;
      paused = false;

      super.openSubState(new OnlinePauseSubState());
      inPause = true;

      paused = realPaused;
      persistentUpdate = true;
      canPause = false;

      return;
    }

    super.openSubState(SubState);
  }

  override function closeSubState()
  {
    if (paused)
    {
      canPause = true;
      inPause = false;
    }

    super.closeSubState();
  }

  function HandleData(packetId:Int, data:Array<Dynamic>)
  {
    OnlinePlayMenuState.RespondKeepAlive(packetId);
    switch (packetId)
    {
      case Packets.PLAYERS_READY:
        var count:Int = data[0];
        waitingText.text = 'Waiting for players ($count/${clientCount})';
      case Packets.EVERYONE_READY:
        var safeFrames:Int = data[0];

        ready = true;
        startCountdown();
        FlxTween.tween(waitingBg, {alpha: 0}, 0.5);
        FlxTween.tween(waitingText, {alpha: 0}, 0.5);

        FlxG.save.data.frames = safeFrames;
        Conductor.recalculateTimings();
      case Packets.BROADCAST_SCORE:
        var id:Int = data[0];
        var score:Int = data[1];

        clientScores[id] = score;
        clientsGroup.members[clientTexts[id]].text = OnlineLobbyState.clients[id] + ": " + score;

      case Packets.PLAYER_LEFT:
        var id:Int = data[0];
        var nickname:String = OnlineLobbyState.clients[id];

        clientsGroup.members[clientTexts[id]].setFormat(24, FlxColor.RED);
        clientsGroup.members[clientTexts[id]].setBorderStyle(FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);

        OnlineLobbyState.removePlayer(id);
        Chat.PLAYER_LEAVE(nickname);
        clientCount--;

      case Packets.REJECT_CHAT_MESSAGE:
        Chat.SPEED_LIMIT();
      case Packets.SERVER_CHAT_MESSAGE:
        Chat.SERVER_MESSAGE(data[0]);

      case Packets.FORCE_GAME_END:
        FlxG.switchState(new OnlineLobbyState(true));

      case Packets.DISCONNECT:
        FlxG.switchState(new OnlinePlayMenuState("Disconnected from server"));
    }
  }

  function SendScore()
  {
    Sender.SendPacket(Packets.SEND_SCORE, [songScore], OnlinePlayMenuState.socket);
  }

  override function update(elapsed:Float)
  {
    super.update(elapsed);

    health = 1;

    if (!ready)
    {
      Conductor.songPosition = -5000;
      Conductor.lastSongPos = -5000;
      songTime = 0;
    }
  }

  override function destroy()
  {
    // This function is called when the State changes. For example, when exiting via the pause menu.
    FlxG.sound.music.onComplete = null;
    /*if (FlxG.sound.music != null)
      FlxG.sound.music.pause();
    if (vocals != null)
    {
      vocals.volume = 0;
      vocals.pause();
    }*/

    FlxG.save.data.frames = originalSafeFrames;
    Conductor.recalculateTimings();

    super.destroy();
  }
}
