include("./Agents.jl")
include("./Items.jl")


module Actions
    import Agents
    import Items

    function vote(registry, candidate, agents)
        pro = 0
        benchmark = length(registry) == 0 ? 0 : mean(registry)
        for agent in agents
            pro += (Agents.evaluate(candidate, agent) > benchmark) ? 1 : 0
        end
        return pro > length(agents)/2;
    end

    function tokenHoldersVote(registry, candidate, agents)
        pro = 0
        quorum = 0
        benchmark = length(registry) == 0 ? 0 : mean(registry)
        for agent in agents
            if agent.balance > 0
                pro += (Agents.evaluate(candidate, agent) > benchmark) ? 1 : 0
                quorum += 1
            end
        end
        return pro > quorum/2;
    end

    function tokenProRataVote(registry, candidate, agents)
        pro = 0
        quorum = 0
        benchmark = length(registry) == 0 ? 0 : mean(registry)
        for agent in agents
            if agent.balance > 0
                pro += (Agents.evaluate(candidate, agent) > benchmark) ? agent.balance : 0
                quorum += agent.balance
            end
        end

        return pro > quorum/2;
    end

    function randomChallenger(agents)
        agents[rand(1:end)]
    end

    function randomWithBalance(agents)
        filteredAgents = filter(a -> a.balance > 10, agents)
        randomChallenger(filteredAgents)
    end

    function noReward(votingResult, challenger, deposit)

    end

    function onlyChallengerReward(votingResult, challenger, deposit)
        challenger.balance += 20.0
    end

    function challenge(registry, agents, challengerSelector, deposit, voteFunc, redistributionFunc)
        if (length(registry) >= 10)
            challenger = challengerSelector(agents)
            challenger.balance -= 10.0
            evaluations = Agents.evaluate.(registry, challenger)
            worstIndex = indmin(evaluations);
            min = evaluations[worstIndex]
            votingResult = voteFunc(registry, min, agents)
            if (!votingResult)
                deleteat!(registry, worstIndex)
            end
            redistributionFunc(votingResult, challenger, deposit)
        end
    end

    function oldChallenge(registry, agents)
        benchmark = length(registry) == 0 ? 0 : mean(registry)
        len = length(registry)
        #println("Len: $len")
        if (length(registry) >= 10)
            challenger = agents[rand(1:end)]
            #println("Challenger: $challenger")
            evaluations = Agents.evaluate.(registry, challenger)
            worstIndex = indmin(evaluations);
            min = evaluations[worstIndex]
            if !vote(registry, min, agents)
                #println("Challenge successful: $min")
                deleteat!(registry, worstIndex)
            else
                #println("Challenge failed: $min")
            end
        end
    end





    function tokenChallenge(registry, agents, voteFunc)
        if (length(agents) > 0)
            benchmark = length(registry) == 0 ? 0 : mean(registry)
            if (length(registry) >= 10)
                challenger = agents[rand(1:end)]
                if (challenger.balance >= 10.0)

                    #println("Challenger: $challenger")
                    evaluations = Agents.evaluate.(registry, challenger)
                    worstIndex = indmin(evaluations);
                    min = evaluations[worstIndex]
                    if !voteFunc(registry, min, agents)
                        #println("Challenge successful: $min")
                        deleteat!(registry, worstIndex)

                    else
                        #println("Challenge failed: $min")
                    end
                else
                    #println("No funds!!!")
                end
            end
        end
    end

    function application(registry, history, agents)
        candidate = Items.getCandidate()
        push!(history, candidate)
        # println("Candidate: $candidate")
        if vote(registry, candidate, agents)
            push!(registry, candidate);
        end
    end

end
