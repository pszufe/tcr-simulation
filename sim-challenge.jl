include("./Agents.jl")
include("./Items.jl")
include("./Actions.jl")
include("./Benchmarks.jl")

import Agents
import Items
import Actions
import Benchmarks

function runSimulation(num_of_steps, num_of_agents, accuracy)
    registry = []
    history = []
    agents = Agents.setupAgentsWithFixedAccuracy(num_of_agents, accuracy)

    for round in 1:num_of_steps
        Actions.application(registry, history, agents)
        Actions.challenge(registry, agents)
    end

    Benchmarks.score(registry)
end


mean([runSimulation(1000, 100, acc) for i in 1:10])


#Run scenario (the impact of accuracy on list quality, 10 iterations)
# for acc in 0:10:100
#     score = mean([runSimulation(1000, 100, acc) for i in 1:10])
#     #println("Accuracy: $acc Score: $score")
#     println("$score")
# end




#
# #RESULTS
# plot(scores, color="blue")
