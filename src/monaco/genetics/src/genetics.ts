export default function geneticAlgorithmConstructor(options: any) {

    function settingDefaults() { return {
 
        mutationFunction : function(phenotype: any) { return phenotype },
 
        crossoverFunction : function(a: any,b: any) { return [a,b] },
 
        fitnessFunction : function(phenotype: any) { return 0 },

        doesABeatBFunction : undefined,
 
        population : [],
        populationSize : 100,
    }}

    function settingWithDefaults( settings: any , defaults: any ) {
        settings = settings || {}

        settings.mutationFunction = settings.mutationFunction || defaults.mutationFunction
        settings.crossoverFunction = settings.crossoverFunction || defaults.crossoverFunction
        settings.fitnessFunction = settings.fitnessFunction || defaults.fitnessFunction

        settings.doesABeatBFunction = settings.doesABeatBFunction || defaults.doesABeatBFunction

        settings.population = settings.population || defaults.population
        if ( settings.population.length <= 0 ) throw Error("population must be an array and contain at least 1 phenotypes")

        settings.populationSize = settings.populationSize || defaults.populationSize
        if ( settings.populationSize <= 0 ) throw Error("populationSize must be greater than 0")

        return settings
    }

    var settings = settingWithDefaults(options,settingDefaults())

    async function populate () {
        var size = settings.population.length
        while( settings.population.length < settings.populationSize ) {
            settings.population.push(
                await mutate(
                    cloneJSON( settings.population[ Math.floor( Math.random() * size ) ] )
                )
            )
        }
    }

    function cloneJSON( object: any ) {
        return JSON.parse ( JSON.stringify ( object ) )
    }

    async function mutate(phenotype: any) {
        return await settings.mutationFunction(cloneJSON(phenotype))
    }

    function crossover(phenotype: any) {
        phenotype = cloneJSON(phenotype)
        var mate = settings.population[ Math.floor(Math.random() * settings.population.length ) ]
        mate = cloneJSON(mate)
        return settings.crossoverFunction(phenotype,mate)[0]
    }

    async function doesABeatB(a: any,b: any) {
        var doesABeatB = false;
        if ( settings.doesABeatBFunction ) {
            return await settings.doesABeatBFunction(a,b)
        } else {
            return await settings.fitnessFunction(a) >= await settings.fitnessFunction(b)
        }
    }

    async function compete( ) {
        var nextGeneration = []

        for( var p = 0 ; p < settings.population.length - 1 ; p+=2 ) {
            var phenotype = settings.population[p];
            var competitor = settings.population[p+1];

            nextGeneration.push(phenotype)
            if ( await doesABeatB( phenotype , competitor )) {
                if ( Math.random() < 0.5 ) {
                    nextGeneration.push(await mutate(phenotype))
                } else {
                    nextGeneration.push(crossover(phenotype))
                }
            } else {
                nextGeneration.push(competitor)
            }
        }

        settings.population = nextGeneration;
    }



    function randomizePopulationOrder( ) {

        for( var index = 0 ; index < settings.population.length ; index++ ) {
            var otherIndex = Math.floor( Math.random() * settings.population.length )
            var temp = settings.population[otherIndex]
            settings.population[otherIndex] = settings.population[index]
            settings.population[index] = temp
        }
    }

    return {
        evolve : async function (options: any | undefined) {

            if ( options ) { 
                settings = settingWithDefaults(options,settings)
            }
            
            await populate()
            randomizePopulationOrder()
            await compete()
            return this
        },
        population : function() {
            return cloneJSON( this.config().population )
        },
        config : function() {
            return cloneJSON( settings )
        },
        clone : function(options: any) {
            return geneticAlgorithmConstructor( 
                settingWithDefaults(options, 
                    settingWithDefaults( this.config(), settings ) 
                    )
                )
        }
    }
}

