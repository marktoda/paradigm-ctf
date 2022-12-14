# Paradigm CTF

Had a great time with the Paradigm CTF this weekend. Hoped to get more done but I got 0xmonaco'd and only spent like 1/4 of the time on the challenges.

## Challenges
### 0xMonaco

I haven't been this excited about a game in a long time, let alone a crypto game (have I ever been excited about one of those before?). I don't even tweet and I [tweeted](https://mobile.twitter.com/MarkToda/status/1561506500899524608) about it [twice](https://mobile.twitter.com/MarkToda/status/1561528894078955521). I already included my progression of cars on twitter but I'll add some interesting tidbits here


**[RampUp](./src/monaco/src/cars/RampUp.sol)**

RampUp was the bread-and-butter on day 1. The main idea was to focus on using `race progression` as a heuristic, where we start off relatively passive and get more aggressive as the race goes on. It defines race progression as the y-value of the first-place car, scaled down to 1-10 so it would be easier to work with.

RampUp mainly scales the amount it's willing to spend for items, always as a proportion of its balance. So, early in the game it may only be willing to spend 1/10 of its money, while later on it would be willing to spend half or more. It also scales the `speed threshold` which it generally always tries to maintain by spending more on boost when below target.


**[PhasedCar](./src/monaco/src/cars/PhasedCar.sol)**

RampUp did really well at first, but started to lose out to economy cars by running out of money. My main thinking was that linear scaling just doesn't cut it -- the marginal value of a boost on turn 100 is exponentially more than on turn 1. But granular exponential curves are hard, so lets do a piecewise function. A piecewise mindset also allowed for strategy changes beyond just item-value scaling.

This is the code I ended up using for the final hours of the competition. It was tweaked soooo many times and got pretty messy :)


**[LearningCar](./src/monaco/src/cars/Learning.sol)**

I got super tired of tweaking parameters for PhasedCar, and started to feel like it wasn't getting any better. There were a lot of parameters that I wanted to include (other players' coin balances, speeds, etc) but nothing seemed to improve PhasedCar's performance. I've seen a [CodeBullet](https://www.youtube.com/c/CodeBullet) video or two, so figured it was time to pit cars against each other in a genetic evolution.

I started by defining valuation functions for the items, returning the current unit cost that the car should be willing to pay. Then had to define a bunch of `weight` parameters that the genetic algorithm can easily tweak to update the valuation functions. 

Finally there is the [Genetics](./src/monaco/genetics/src/index.ts) script which randomly generates mutations and attempts to move towards an (at least local) optimum weighting. The fitness function is generated by running a given car phenotype against a set of various cars and summing the score for each race, where the score is:
- the distance behind first if the phenotype didn't get first
- flat 100 points if we got first (don't want to over-incentivize getting first by a wide margin)

I set it up with some sane defaults and let it run all night, hoping to wake up to the most perfectly optimal car in history. The car I woke up to was great -- it could beat every other manually-generated car I had! I pushed it up to 0xmonaco and... it sucked. It sat at the starting blocks and shot a bunch of shells at second place until the very end of the race. Obviously it overfitted, but I think its strategy was to make the other cars run out of money and come from behind to win. Bold.

I spent a bit longer trying to get a better result but ended up giving up and going back to tinkering with PhasedCar.


### Sourcecode

Worked on this one first, it looked pretty easy. Just have to generate some bytecode that returns the code at its own address. I planned on writing a simple contract to return `address(this).code` in the fallback, get the bytecode and post that. 3 minutes later I was stoked to be already done with a challenge .... `Reverted: deploy/code-unsafe`. shit, (ext)codecopy is an unsafe opcode. 

Later on I was doing some googling and found this helpful [hint](https://mobile.twitter.com/0xkarmacoma/status/1554246286290735104). Problem though, it includes `codesize` as a hack to `push 0x0` in a single byte, but thats also off-limits. Adding even a single extra byte complicates the code quite a bit so I was really hoping to make it work. No dice though (though it is [possible](https://mobile.twitter.com/z0age/status/1561530968158208003)).

An hour of [docs](https://docs.soliditylang.org/en/v0.8.16/) and [evm.codes](https://www.evm.codes/) later I had something that [worked](./test/Source.t.sol)!

This one ended up being really fun, it felt great to hack out some raw bytecode that does what I want. Though in hindsight the bytecode-development process would have been much easier with [etk](https://quilt.github.io/etk/).


### Reversing

I wanted this one so bad. I had a lot of fun stepping through the [bytecode](./test/Reversing.t.sol) in the forge debugger and slowly putting it together. Right when I thought I was getting close, forge test [crashed my entire computer](https://github.com/foundry-rs/foundry/issues/2870) and I didn't have any other tools I liked enough to keep going. 0xMonaco was calling my name anyway
