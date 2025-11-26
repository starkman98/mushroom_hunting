StressConfig = {}

StressConfig.stress = {
    enabled = true,
    default = 20,
    min = 0,
    max = 100,
    effectTick = 5, -- when stress decreases it runs the effect every N stress value ex 20, 15, 10
    activeLevel = nil,
    
    levelValues = {
        low = 1,
        medium = 2,
        high = 3
    },
    
    levels = {
        low = 10,
        medium = 60,
        high = 80
    },
    
    increase = {
        criminalActivities = 5,
    },

    decrease = {
        mushroomPick = 5,
    }
}