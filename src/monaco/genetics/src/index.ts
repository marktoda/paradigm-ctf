import { exec } from 'child_process';
import fs from 'fs';
import Genetics from './genetics';
import util from 'util';

const execPromise = util.promisify(exec);

const testFile = '../test/Monaco.t.sol'
const carFile = '../src/cars/Learning.sol'
const car2File = '../src/cars/Learning2.sol'
const car3File = '../src/cars/Learning3.sol'
const ANALYTICAL_ADDRESS = '0xefc56627233b02ea95bae7e19f648d7dcd5bb132';


async function main() {
  const weights1 = [-2,2181,1515,-2088,-1802,-1680,9,1,791,3696,-3201,0,-1539,-1240];

  const config = {
    mutationFunction: mutate,
    crossoverFunction: crossover,
    fitnessFunction: fitness,
    // doesABeatBFunction: doesABeatB,
    population: [{ weights: weights1 }],
    populationSize: 3 	// defaults to 100
  }
  const gen = Genetics(config)
  console.log(gen);

  for( let loop = 1 ; loop <= 1000 ; loop++ ) {
    await gen.evolve(undefined)
  }
}

interface Phenotype {
  weights: number[],
}

let bestFitness = -200;
let bestWeights: number[] = [0,1122,983,1133,911,1368,946,875,889,995,914,1097, 1000, 1000];
let oldBestWeights: number[] = [-2,1751,4573,5455,-1245,0,1705,3943,2947,71724,1391,4662, 1000, 1000];

async function fitness(phenotype: Phenotype): Promise<number> {
  updateFile(phenotype.weights);
  updateFile(bestWeights, car2File);
  updateFile(oldBestWeights, car3File);
  const fitness = await runTestWithCompetitor("ShellCar", "ShellCar") + await runTestWithCompetitor("FifthCar", "FifthCar") + await runTestWithCompetitor("Learning2", "LearningCar2") + await runTestWithCompetitor("Learning3", "LearningCar3");
  if (fitness >= bestFitness && !arrayEquals(phenotype.weights, bestWeights)) {
    oldBestWeights = bestWeights;
    bestFitness = fitness;
    bestWeights = phenotype.weights;
  console.log(`New BEST! ${fitness}: ${phenotype.weights}`);
  }

  console.log(`fitness for weights: ${fitness} -- ${phenotype.weights}`);
  console.log(`best fitness so far: ${bestFitness} -- ${bestWeights}`);
  console.log();
  return fitness;
}

async function mutate(phenotype: Phenotype): Promise<Phenotype> {
  const newWeights: number[] = [];
  for (const weight of phenotype.weights) {
    const shouldChange = Math.floor(Math.random() * 2) + 1;
    if (shouldChange) {
      const crazy = Math.floor(Math.random() * 10) + 1;
      const changeDirection = Math.floor(Math.random() * 2);
      if (crazy == 7) {
        const crazyFactor = (Math.floor(Math.random() * 5) + 1) / 2;
        if (changeDirection == 0) {
          console.log('CRAZY!, subtracting', Math.floor(weight * crazyFactor));
          newWeights.push(weight - Math.floor(((weight + 1) * crazyFactor)));
        } else {
          console.log('CRAZY!, adding', Math.floor(weight * crazyFactor));
          newWeights.push(weight + Math.floor(((weight + 1) * crazyFactor)));
        }
      } else {
        const changePercent = Math.floor(Math.random() * 10) + 1;
        if (changeDirection == 0) {
          newWeights.push(weight - Math.floor((weight * changePercent / 100)));
        } else {
          newWeights.push(weight + Math.floor((weight * changePercent / 100)));
        }
      }


    } else {
      newWeights.push(weight);
    }

  }
  return { weights: newWeights };
}

function crossover(a: Phenotype, b: Phenotype): Phenotype[] {
  for (let i = 0; i < a.weights.length; i++) {
    const random = Math.floor(Math.random() * 10);
    if (random == 7) {
      console.log('crossover', a.weights[i], b.weights[i]);
      const temp = a.weights[i];
      a.weights[i] = b.weights[i];
      b.weights[i] = temp;
    }
  }
  return [a, b];
}

async function doesABeatB(a: Phenotype, b: Phenotype): Promise<boolean> {
  const aFitness = await fitness(a);
  const bFitness = await fitness(b);
  if (aFitness > 0 && bFitness < 0) return true;
  if (aFitness < 0 && bFitness > 0) return false;

  updateFile(a.weights, carFile);
  updateFile(b.weights, car2File);
  const test = fs.readFileSync(testFile, 'utf-8').split('\n');
  const prevImport = test[7];
  test[7] = 'import "../src/cars/Learning2.sol";';
  const prevCreation = test[19];
  test[19] = 'LearningCar2 w1 = new LearningCar2(monaco);';
  fs.writeFileSync(testFile, test.join('\n'), 'utf-8');
  const analytical2Address = '0x185a4dc360CE69bDCceE33b3784B0282f7961aea';

  const { stdout } = await execPromise('forge test --root ../monaco/ -vv');
  const runs = stdout.split(/\n\s*\n/);
  const finish = runs[runs.length - 2];
  const line = finish.split('\n');

  let aY: number;
  let bY: number;

  for (let i = 0; i < 3; i++) {
    const address = line[i * 4].trim();
    const y = parseInt(line[i * 4 + 3].split(': ')[1]);
    if (address.toLowerCase() === ANALYTICAL_ADDRESS.toLowerCase()) {
      aY = y;
    } else if (address.toLowerCase() === analytical2Address.toLowerCase()) {
      bY = y;
    }
  }

  test[7] = prevImport;
  test[19] = prevCreation;
  fs.writeFileSync(testFile, test.join('\n'), 'utf-8');
  const aWins = aY > bY;
  console.log()
  console.log(`${aWins ? 'A' : 'B'} wins!`);
  console.log(`A fitness ${aFitness} -- y ${aY} -- ${a.weights}`);
  console.log(`B fitness ${bFitness} y ${bY} -- ${b.weights}`);
  console.log()
  return aY > bY;
}

async function runTestWithCompetitor(fileName: string, carName: string): Promise<number> {
  const test = fs.readFileSync(testFile, 'utf-8').split('\n');
  const prevImport = test[7];
  test[7] = `import "../src/cars/${fileName}.sol";`;
  const prevCreation = test[19];
  test[19] = `${carName} w1 = new ${carName}(monaco);`;
  fs.writeFileSync(testFile, test.join('\n'), 'utf-8');


  const { stdout } = await execPromise('forge test --root ../monaco/ -vv');
  const runs = stdout.split(/\n\s*\n/);
  const finish = runs[runs.length - 2];
  const line = finish.split('\n');
  if (line.length < 8) return 0;

  const bestY = parseInt(line[3].split(': ')[1]);
  let secondY = parseInt(line[7].split(': ')[1]);
  let ourY = 0;

  for (let i = 0; i < 3; i++) {
    const address = line[i * 4].trim();
    const y = parseInt(line[i * 4 + 3].split(': ')[1]);
    if (address.toLowerCase() === ANALYTICAL_ADDRESS.toLowerCase()) {
      ourY = y;
    }
  }

  test[7] = prevImport;
  test[19] = prevCreation;
  fs.writeFileSync(testFile, test.join('\n'), 'utf-8');

  if (ourY == bestY) {
    console.log(`Score against ${carName}: 100`);
    return 100;
  } else {
    console.log(`Score against ${carName}: ${ourY - bestY}`);
    return ourY - bestY;

  }
}

function updateFile(weights: number[], file=carFile) {
  const car = fs.readFileSync(file, 'utf-8');
  let i = 0;
  let j = 0;
  let output = '';
  for (const line of car.split('\n')) {
    if (i < 30 && line.includes('WEIGHT') && line.includes('=')) {
      const split = line.split('=');
      split[split.length - 1] = ' ' + weights[j].toString() + ';';
      output += split.join('=') + '\n';
      j++;
    } else {
      output += line + '\n';
    }
    i++;
  }
  fs.writeFileSync(file, output, 'utf-8');
}

function arrayEquals(a: number[], b: number[]): boolean {
  return Array.isArray(a) &&
    Array.isArray(b) &&
    a.length === b.length &&
    a.every((val, index) => val === b[index]);
}

void main();
