local mod = FiendFolio

local worldHitJokeLines = {
	[200] = [[
please stop
]],
	[500] = [[
stop that!
]],
	[650] = [[
I mean it!
stop that!
]],
	[700] = [[
dude
come on
]],
	[750] = [[
ok
]],
	[760] = [[
OKAY!
]],
	[770] = [[
OKAYYYYYY!!!
]],
	[780] = [[
I GET IT!!
]],
	[800] = [[
you must think this
is soooo hilarious
]],
	[850] = [[
I ain't laughing bro
]],
	[900] = [[
is anyone else?
]],
	[955] = [[
you impressing
some discord friends?
]],
	[980] = [[
youtube crowd?
]],
	[1000] = [[
twitter followers?
]],
	[1020] = [[
twitch chat?
]],
	[1050] = [[
got like a hot date
who's really into this?
]],
	[1100] = [[
if that last one's true
then that's a red flag
if i ever saw one
]],
	[1150] = [[
"one minute honey i'm
busy throwing virtual
metal against a wall"
]],
	[1200] = [[
someone out there
for everyone
i suppose
]],
	[1300] = [[
well uh
]],
	[1350] = [[
I guess I'll
come back in a bit
]],
	[1400] = [[
don't want to disturb
your important work
]],
	[1450] = [[
hey i know!
]],
	[1465] = [[
you should try for
1000 more hits!
]],
	[1500] = [[
see you then!
]],
	[2500] = [[
you're really still
doing this, huh
]],
	[2550] = [[
it's impressive
]],
	[2565] = [[
in a sad sort of way
]],
	[2600] = [[
but i do mean it
]],
	[2650] = [[
you even got that
whole 1000 hits!
]],
	[2680] = [[
give or take a few
]],
	[2700] = [[
i'm not the
best counter
]],
	[2800] = [[
so where are you
in your run anyhow?
]],
--Lol, all the specific floors holy shit
--Why did I even do that
	[3000] = [[
Anyway
]],
	[3050] = [[
Hearing this clanging
noise over and over
]],
	[3075] = [[
Has definitely gotten 
me to think about
some things...
]],
	[3125] = [[
for starters...
]],
	[3150] = [[
I'm really sick of
hearing you clanging
over and over
]],
	[3200] = [[
there...
]],
	[3300] = [[
hmmm...
]],
	[3350] = [[
I suppose that's
still not quite
right huh...
]],
	[3400] = [[
you can still get your 
dumb little kicks out
of a swishing noise
]],
	[3450] = [[
a true testament
to your ability to
annoy me...
]],
	[3500] = [[
but no matter...
]],
	
	[3550] = [[
I have just
the solution
]],
	[3600] = [[
how about this?
]],
	[3700] = [[
such bliss
pure silence
]],
	[3750] = [[
it does feel
a tad weird now
however...
]],
	[3800] = [[
video games need
to have gamefeel!
]],
	[3850] = [[
and a hook with no
sounds just doesn't
have gamefeel!
]],
	[3900] = [[
hang on for just
a moment! I have
to find something
]],
	[4000] = [[
a hah! I found
the perfect sound
to appease you
]],
	[4050] = [[
try it now!
]],
	[4100] = [[
oh god no
]],
	[4150] = [[
to tell the truth
i put that on to
try and annoy you
]],
	[4200] = [[
i think it bothered
me more than anything,
heh...
]],
	[4300] = [[
well uh, any plans?
you're getting closer
and closer to 5000 hits!
]],
	[4350] = [[
hey, tell you what
]],
	[4400] = [[
if you can reach
5000 hits
]],
	[4450] = [[
i'll give you back
your cleaver sounds
]],
	[4500] = [[
deal?
deal.
]],
	[4600] = [[
hmm I did disable
those for a reason...
]],
	[4650] = [[
ah screw it, you
need dedication
at this point
]],
	[4700] = [[
because it really
is impressive you've
kept it going so long
]],
	[4750] = [[
like again, I do
genuinely mean it!
]],
	[4800] = [[
i don't get it
but it's a feat
nonetheless
]],
	[4950] = [[
getting close now...
]],
	[4990] = [[
almost...
]],
	[5000] = [[
they're back!
]],
	[5010] = [[
AAA TOO LOUD
]],
	[5050] = [[
Sorry about that...
]],
	[5100] = [[
are you sure
this was worth it?
]],
	[5150] = [[
well I guess you
did want to earn it
]],
	[5200] = [[
hm, perhaps you
should go for gold
]],
	[5250] = [[
5000 is such a
measly number
don't you think?
]],
	[5300] = [[
how about going
for 10000?
]],
	[5350] = [[
it's a nice
power of 10
after all
]],
	[5400] = [[
in the meantime
i'll go buy
some earmuffs
]],
	[7500] = [[
hello!
]],
	[7550] = [[
just checking in!
]],
	[7600] = [[
the silence was quite
nice on my ears while
i was away there...
]],
	[7650] = [[
anyway, I just
wanted to let you know
you passed the 7500 mark!
]],
	[7700] = [[
woooo!!!
big time scorer!
]],
	[7750] = [[
this does leave you
with 2250 hits left
]],
	[7800] = [[
because you've now
done about 300 hits
since I got back!
]],
	[7850] = [[
that's impressive!
so fast!
]],
	[7900] = [[
anyway, since you've
still got a good
few hits left...
]],
	[7950] = [[
i'm gonna just
take my leave
until then
]],
	[8000] = [[
keep it up!
proud of you!
]],
	[8100] = [[
oh! I did
forget to mention
]],
	[8150] = [[
couldn't find any
earmuffs sadly...
]],
	[9000] = [[
it's over
9000!!!!
]],
	[9050] = [[
haha
couldn't resist
]],
	[9500] = [[
hi again
]],
[9550] = [[
you've now passed
the 9500 mark!
]],
[9600] = [[
so you're getting
real close now
]],
[9650] = [[
but to be
honest...
]],
[9700] = [[
as you
approach it
]],
[9750] = [[
does the reward
really seem all
that worth it?
]],
[9800] = [[
was it really
that hard to get?
]],
[9850] = [[
we can go
much higher...
]],
[9900] = [[
what if we
shot straight
for the moon!
]],
[9950] = [[
screw 10,000
screw 100,000
we shoot for...
]],
[10000] = [[
a million
]],
[10050] = [[
we already
passed 10,000
]],
[10100] = [[
but see it didn't
feel all that
accomplishing
]],
[10150] = [[
see you in
989850
more hits!
]],
[1000000] = [[
nice work!
you reached a million!
]],
[1000050] = [[
wait a minute...
]],
[1000100] = [[
why is it called
isaac rebuilt when
that was about deimos
]],
[1000150] = [[
sanford was the one
who used the hook in
that youtube show!
]],
[1000200] = [[
I don't even think
you should play this
challenge anymore now
]],
[1000250] = [[
here
just take the
trophy and go
]],
[1000300] = [[
and enjoy that
golden hook too
]],
[1000350] = [[
just know that you're
not the first to do this
]],
[1000400] = [[
sir peno managed
to achieve that...
]],
[1000450] = [[
well i've wasted
enough of your time!
]],
[1000500] = [[
buh bye!
]],
[1005000] = [[
do not try and
go for 10,000,000
]],
[1005050] = [[
there is nothing there
]],
[10000000] = [[
hi you reached
10,000,000
]],
[10000050] = [[
why
]],
[10000100] = [[
how many hours
did this take?!
]],
[10000200] = [[
well there's nothing
else after this
so go away
]],
[100000000] = [[
100,000,000...
please stop
]],
[1000000000] = [[
a billion is
far too much!
]],
[1000000100] = [[
but congrats?
]],
[1000000200] = [[
you don't get
anything......
]],
[1000000300] = [[
goodbye for real now
]],
[10000000000] = [[
please stop
for your own sake
]],
[100000000000] = [[
just 900,000,000,000
more to go i suppose
]],
[1000000000000] = [[
one fucking trillion
]],
[1000000000100] = [[
christ alive
you really did it
]],
[1000000000200] = [[
not legitimately
i must assume
]],
[1000000000300] = [[
now please stop
]],
[1000000000400] = [[
that's it!
no more!
]],
}

local worldHitJokeLinesFloorSpecific = {
    [2850] = {
        [0] = { --Start room
            [StageType.STAGETYPE_ORIGINAL] = [[
I see you've not even
left the start room!
]],
        },
        [101] = { --Mom alive
            [StageType.STAGETYPE_ORIGINAL] = [[
AAH!
SHE'S STILL ALIVE!
]],
        },
        [100] = { --Mom dead
            [StageType.STAGETYPE_ORIGINAL] = [[
Oh huh
you beat the
challenge!
]],
        },
        [34] = { --Ascent
            [StageType.STAGETYPE_ORIGINAL] = [[
Oh nice!
You reached the
ascent path!
]],
        },
        [150] = { --BossRush
            [StageType.STAGETYPE_ORIGINAL] = [[
Oh I see, you're
in boss rush!
]],
        },
        [LevelStage.STAGE1_1] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
Ah, you stopped dead
right in basement I...
]],
            [StageType.STAGETYPE_WOTL] = [[
Hmm, you're in
Cellar I with barely
any progress...
]],
            [StageType.STAGETYPE_AFTERBIRTH] = [[
Aah, you stopped
in Burning Basement I
]],
            [StageType.STAGETYPE_REPENTANCE] = [[
Uh, you're in
downpour???
]],
            [StageType.STAGETYPE_REPENTANCE_B] = [[
What the hell are
you doing in Dross?
]],
        },
        [LevelStage.STAGE1_2] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
Oh alright...
you made it
to Basement II
]],
            [StageType.STAGETYPE_WOTL] = [[
got to Cellar II
and had enough, huh
]],
            [StageType.STAGETYPE_AFTERBIRTH] = [[
Basement II is
a fair place to
stop I suppose
]],
        },
        [LevelStage.STAGE2_1] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
You chickened out
at the start of Caves?
]],
            [StageType.STAGETYPE_WOTL] = [[
Aah caves I
no wait
catacombs I
]],
            [StageType.STAGETYPE_AFTERBIRTH] = [[
Not a big flooded
caves fan I take it?
]],
            [StageType.STAGETYPE_REPENTANCE] = [[
At this point I'm
just confused how
you're in Mines.
]],
            [StageType.STAGETYPE_REPENTANCE_B] = [[
Oh I love Ashpit!
]],
        },
        [LevelStage.STAGE2_2] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
Oh you're on
caves II!
]],
            [StageType.STAGETYPE_WOTL] = [[
catacombs ii!
neat!
]],
            [StageType.STAGETYPE_AFTERBIRTH] = [[
oh boy
flooded caves II
]],
        },
        [LevelStage.STAGE3_1] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
ah hah! you've
reached the depths!
]],
            [StageType.STAGETYPE_WOTL] = [[
Ah, you've been
wasting time in
necropolis eh?
]],
            [StageType.STAGETYPE_AFTERBIRTH] = [[
oh i see
you're in the
dank depths
]],
            [StageType.STAGETYPE_REPENTANCE] = [[
hmm, i see
that you're in
mausoleum somehow
]],
            [StageType.STAGETYPE_REPENTANCE_B] = [[
now you're normally
not meant to be
on gehenna here
]],
        },
        [LevelStage.STAGE3_2] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
oooh depths II
you're getting
close to the end
]],
            [StageType.STAGETYPE_WOTL] = [[
oh man!
necropolis II!
]],
            [StageType.STAGETYPE_AFTERBIRTH] = [[
dank depths ii
hahaha, right at
the end of the run
]],
        },
        [LevelStage.STAGE4_1] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
oh huh you're
in the womb
]],
            [StageType.STAGETYPE_WOTL] = [[
i didn't expect
to see you in
the utero
]],
            [StageType.STAGETYPE_AFTERBIRTH] = [[
eurgh,
scarred womb
]],
            [StageType.STAGETYPE_REPENTANCE] = [[
Corpse?!?!
]],
            [StageType.STAGETYPE_REPENTANCE_B] = [[
What the hell?
Mortis?!?!?!
]],
        },
        [LevelStage.STAGE4_3] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
Interesting
you got to
blue womb
]],
        },
        [LevelStage.STAGE5] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
Hoohoo, sheol!
]],
            [StageType.STAGETYPE_WOTL] = [[
Oh my!
You're in cathederal!
]],
        },
        [LevelStage.STAGE6] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
Oh cool, you got
to the dark room!
]],
            [StageType.STAGETYPE_WOTL] = [[
Aaaah the chest!
]],
        },
        [LevelStage.STAGE7] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
Pffft, you got
to the void...
]],
        },
        [LevelStage.STAGE8] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
Home?
]],
        },
    },
    [2900] = {
        [0] = { --Start room
        [StageType.STAGETYPE_ORIGINAL] = [[
Well I hope
you're having fun
]],
            [StageType.STAGETYPE_WOTL] = [[
Is cellar just
too hard for you?
]],
            [StageType.STAGETYPE_AFTERBIRTH] = [[
Granted it is
burning basement
]],
            [StageType.STAGETYPE_REPENTANCE] = [[
Granted i have
no clue how you
started here
]],
            [StageType.STAGETYPE_REPENTANCE_B] = [[
Granted i have
no clue how you
started here
]],
        },
        [101] = { --Mom alive
            [StageType.STAGETYPE_ORIGINAL] = [[
KILL HER!
KILL HER!
KILL HER!
]],
        },
        [100] = { --Mom dead
            [StageType.STAGETYPE_ORIGINAL] = [[
Congratulations!
]],
        },
        [34] = { --Ascent
            [StageType.STAGETYPE_ORIGINAL] = [[
Wait...
that's not meant
to be possible!
]],
        },
        [150] = { --BossRush
            [StageType.STAGETYPE_ORIGINAL] = [[
Going for a good
old fashioned
victory lap!
]],
        },
        [LevelStage.STAGE1_1] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
You really got
bored that quickly?
]],
            [StageType.STAGETYPE_WOTL] = [[
I wonder if you got
stuck in a cobweb...
]],
            [StageType.STAGETYPE_AFTERBIRTH] = [[
I don't blame you
for finding this
way more fun.
]],
            [StageType.STAGETYPE_REPENTANCE] = [[
I don't think
you're supposed to
be on this floor.
]],
            [StageType.STAGETYPE_REPENTANCE_B] = [[
I don't think
you're supposed to
be on this floor.
]],
        },
        [LevelStage.STAGE1_2] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
you realise this
does go all the way
to the mom fight?
]],
            [StageType.STAGETYPE_WOTL] = [[
well i suppose it
is a harder floor
]],
            [StageType.STAGETYPE_AFTERBIRTH] = [[
especially if you
had it twice in a
row or something
]],
        },
        [LevelStage.STAGE2_1] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
It's not that
difficult I promise!
]],
            [StageType.STAGETYPE_WOTL] = [[
my bad, the floors
are very samey
]],
            [StageType.STAGETYPE_AFTERBIRTH] = [[
That's ok, because
the mod adds a ton
of new content there!
]],
            [StageType.STAGETYPE_REPENTANCE] = [[
You got any mods
installed to go
there or something?
]],
            [StageType.STAGETYPE_REPENTANCE_B] = [[
Wait, but you're in
a challenge run that
goes on the main path.
]],
        },
        [LevelStage.STAGE2_2] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
You're practically
more than halfway
through the run!
]],
            [StageType.STAGETYPE_WOTL] = [[
i'm a fan of the
weird enemies this
floor often has.
]],
            [StageType.STAGETYPE_AFTERBIRTH] = [[
now this floor is
certainly tricky
i'll give you that
]],
        },
        [LevelStage.STAGE3_1] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
now it may seem
tough but don't
get too worried
]],
            [StageType.STAGETYPE_WOTL] = [[
big fan of the
music are you?
]],
            [StageType.STAGETYPE_AFTERBIRTH] = [[
are you stick
in big pile of
tar somehow?
]],
            [StageType.STAGETYPE_REPENTANCE] = [[
this one guy on
the team is a freak
and looooves that floor
]],
            [StageType.STAGETYPE_REPENTANCE_B] = [[
are you some kind
of pervert that really
wants to be in gehenna?
]],
        },
        [LevelStage.STAGE3_2] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
aaah, now i know
why you're stood
here spammin this
]],
            [StageType.STAGETYPE_WOTL] = [[
you're so close
to mom now!
]],
            [StageType.STAGETYPE_AFTERBIRTH] = [[
just gotta get
through some more
ickiness to finish
]],
        },
        [LevelStage.STAGE4_1] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
always fun to keep
a good challenge going!
]],
            [StageType.STAGETYPE_WOTL] = [[
hehe, see...
]],
            [StageType.STAGETYPE_AFTERBIRTH] = [[
this floor is
honestly so
gross to me
]],
            [StageType.STAGETYPE_REPENTANCE] = [[
you're definitely
not meant to be here
]],
            [StageType.STAGETYPE_REPENTANCE_B] = [[
This stage literally
is not meant to
exist right now.
]],
        },
        [LevelStage.STAGE4_3] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
spamming this much
probably took less time
than the boss fight
]],
        },
        [LevelStage.STAGE5] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
You gonna take out
satan himself?
]],
            [StageType.STAGETYPE_WOTL] = [[
I can't say I
expected to see
this floor.
]],
        },
        [LevelStage.STAGE6] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
i assume you must've
used a sacrifice room
or something like that
]],
            [StageType.STAGETYPE_WOTL] = [[
What route did
you even take to
get here?
]],
        },
        [LevelStage.STAGE7] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
Did one of delirium's
little portals
suck you in?
]],
        },
        [LevelStage.STAGE8] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
But...
you can't even go
to the ascent route!
]],
        },
    },
    [2950] = {
        [0] = { --Start room
            [StageType.STAGETYPE_ORIGINAL] = [[
feel free to begin
the run anytime!
]],
            [StageType.STAGETYPE_WOTL] = [[
or maybe you're
scared of spiders
]],
            [StageType.STAGETYPE_AFTERBIRTH] = [[
so i really
can't blame you
]],
            [StageType.STAGETYPE_REPENTANCE] = [[
well, keep me updated
on what happens
]],
            [StageType.STAGETYPE_REPENTANCE_B] = [[
well, keep me updated
on what happens
]],
        },
        [101] = { --Mom alive
            [StageType.STAGETYPE_ORIGINAL] = [[
NO!
STOP SPAMMING
AND KILL HER!
]],
        },
        [100] = { --Mom dead
            [StageType.STAGETYPE_ORIGINAL] = [[
Feel free to
take the trophy
anytime I guess.
]],
        },
        [34] = { --Ascent
            [StageType.STAGETYPE_ORIGINAL] = [[
and no, transcendence
through the hook is
not possible!
]],
        },
        [150] = { --BossRush
            [StageType.STAGETYPE_ORIGINAL] = [[
Just try not to
die in here
okay?
]],
        },
        [LevelStage.STAGE1_1] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
there's a whole
lot more game y'kno
]],
            [StageType.STAGETYPE_WOTL] = [[
hopefully you can
free yourself soon!
]],
            [StageType.STAGETYPE_AFTERBIRTH] = [[
you have to
continue eventually...
]],
            [StageType.STAGETYPE_REPENTANCE] = [[
just restart and
maybe it'll fix itself
]],
            [StageType.STAGETYPE_REPENTANCE_B] = [[
just restart and
maybe it'll fix itself
]],
        },
        [LevelStage.STAGE1_2] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
just promise you'll
at least reach mom
this year okay?
]],
            [StageType.STAGETYPE_WOTL] = [[
try playing again
when you're older
]],
            [StageType.STAGETYPE_AFTERBIRTH] = [[
just don't burn out
by doing this okay?
]],
        },
        [LevelStage.STAGE2_1] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
you can get
past this floor
in no time!
]],
            [StageType.STAGETYPE_WOTL] = [[
that's no reason
to just stop and
spam the hook though.
]],
            [StageType.STAGETYPE_AFTERBIRTH] = [[
The lily pads are
definitely intense
though, good luck!
]],
            [StageType.STAGETYPE_REPENTANCE] = [[
If so mind letting
me know the name of
those cool mods?
]],
            [StageType.STAGETYPE_REPENTANCE_B] = [[
Well I'm gonna enjoy
seeing this floor
either way!
]],
        },
        [LevelStage.STAGE2_2] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
If you don't count
stopping to spam
the hook that is.
]],
            [StageType.STAGETYPE_WOTL] = [[
i hope they
add vampires
or bears soon
]],
            [StageType.STAGETYPE_AFTERBIRTH] = [[
don't be nervous
though! you can
beat this floor!
]],
        },
        [LevelStage.STAGE3_1] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
just this and
the next floor and
you'll reach mom!
]],
            [StageType.STAGETYPE_WOTL] = [[
da da da
dadadada
]],
            [StageType.STAGETYPE_AFTERBIRTH] = [[
i don't see why else
you'd be wasting
all this time
]],
            [StageType.STAGETYPE_REPENTANCE] = [[
wait, maybe you're them 
and modded the game
to be on that floor?!?!
]],
            [StageType.STAGETYPE_REPENTANCE_B] = [[
I mean I don't judge
but c'mon, this
challenge is main path
]],
        },
        [LevelStage.STAGE3_2] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
you want to spend
more time in this
awesome challenge!
]],
            [StageType.STAGETYPE_WOTL] = [[
reduce her to
a skeleton!!!
]],
            [StageType.STAGETYPE_AFTERBIRTH] = [[
but then you
can move on
with your life!
]],
        },
        [LevelStage.STAGE4_1] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
how far can you
even make it?
]],
            [StageType.STAGETYPE_WOTL] = [[
get it?
because the eyes?
]],
            [StageType.STAGETYPE_AFTERBIRTH] = [[
please just try
to get out of
here sooner!
]],
            [StageType.STAGETYPE_REPENTANCE] = [[
but uh, can you
beat witness?
i mean mother?
]],
            [StageType.STAGETYPE_REPENTANCE_B] = [[
Or maybe this
is in the future
when it released...
]],
        },
        [LevelStage.STAGE4_3] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
well, i guess you're
thoroughly ready
to face him now
]],
        },
        [LevelStage.STAGE5] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
Shame you can't
reach dark room
this way though!
]],
            [StageType.STAGETYPE_WOTL] = [[
I guess neither
did you, that's why
you're just doing this.
]],
        },
        [LevelStage.STAGE6] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
I can understand the
hesitation to continue
this run forwards!
]],
            [StageType.STAGETYPE_WOTL] = [[
I wish you luck
either way!
]],
        },
        [LevelStage.STAGE7] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
I can get not
wanting to play
on this floor...
]],
        },
        [LevelStage.STAGE8] = {
            [StageType.STAGETYPE_ORIGINAL] = [[
Good luck with beast?
]],
        },
    },
}

local spamHits = {
    [6] = true,
    [10] = true,
    [14] = true,
}

function mod:sanguineHookWorldHitJoke(e, d)
	local p = e.Parent
	local pd = p:GetData()
	pd.timeSinceLastHitSanguineHookAgainstWall = pd.timeSinceLastHitSanguineHookAgainstWall or 0
    if spamHits[pd.timeSinceLastHitSanguineHookAgainstWall] then
		local sd = FiendFolio.savedata.run
		sd.SanguineHookSpamHits = sd.SanguineHookSpamHits or 0
        --[[if pd.timeSinceLastHitSanguineHookAgainstWall == 6 then
            sd.SanguineHookSpamHits = 2900
        elseif pd.timeSinceLastHitSanguineHookAgainstWall == 10 then
            sd.SanguineHookSpamHits = 2950
        elseif pd.timeSinceLastHitSanguineHookAgainstWall == 14 then
            sd.SanguineHookSpamHits = 2850
        end]]
		sd.SanguineHookSpamHits = sd.SanguineHookSpamHits + 1
        --print(sd.SanguineHookSpamHits, pd.timeSinceLastHitSanguineHookAgainstWall)
        local floorSpecificLine
		if worldHitJokeLinesFloorSpecific[sd.SanguineHookSpamHits - 1] then
            local level = Game():GetLevel()
            local levelstage = level:GetStage()
            local stagetype = level:GetStageType()
            local room = Game():GetRoom()
            local roomDesc = level:GetCurrentRoomDesc()
            local roomsub = roomDesc.Data.Subtype
            if not sd.HasLeftStartRoom then
                levelstage = 0
            elseif roomsub == 6 and room:GetType() == RoomType.ROOM_BOSS then
                if room:IsClear() then
                    levelstage = 100
                else
                    levelstage = 101
                end
            elseif level:IsAscent() then
                levelstage = 34
            elseif room:GetType() == RoomType.ROOM_BOSSRUSH then
                levelstage = 150
            end
            if not worldHitJokeLinesFloorSpecific[sd.SanguineHookSpamHits - 1][levelstage] then
                if worldHitJokeLinesFloorSpecific[sd.SanguineHookSpamHits - 1][levelstage - 1] then
                    levelstage = levelstage - 1
                end
            end
            if worldHitJokeLinesFloorSpecific[sd.SanguineHookSpamHits - 1][levelstage] then
                if not worldHitJokeLinesFloorSpecific[sd.SanguineHookSpamHits - 1][levelstage][stagetype] then
                    if worldHitJokeLinesFloorSpecific[sd.SanguineHookSpamHits - 1][levelstage - 1] and worldHitJokeLinesFloorSpecific[sd.SanguineHookSpamHits - 1][levelstage - 1][stagetype] then
                        levelstage = levelstage - 1
                    else
                        stagetype = StageType.STAGETYPE_ORIGINAL
                    end
                end
                if worldHitJokeLinesFloorSpecific[sd.SanguineHookSpamHits - 1][levelstage][stagetype] then
                    --print(level:GetAbsoluteStage(), stagetype)
                    floorSpecificLine = worldHitJokeLinesFloorSpecific[sd.SanguineHookSpamHits - 1][levelstage][stagetype]
                end
            end
        end
        if floorSpecificLine then
            mod:ShowFortune(floorSpecificLine, true)
        elseif worldHitJokeLines[sd.SanguineHookSpamHits - 1] then
			mod:ShowFortune(worldHitJokeLines[sd.SanguineHookSpamHits - 1], true)
		end
        if sd.SanguineHookSpamHits - 1 == 1000250 then
            local room = Game():GetRoom()
            local spawnpos = room:FindFreePickupSpawnPosition(room:GetCenterPos(), 20)
	        Isaac.Spawn(5, 370, 0, spawnpos, Vector.Zero, nil)
            FiendFolio.savedata.goldenSanguineHookUnlocked = true
        end
	end
	pd.timeSinceLastHitSanguineHookAgainstWall = 0
end