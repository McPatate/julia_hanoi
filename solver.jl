num_disks = 8

all_disks = 1:num_disks

first_stack = collect(all_disks)

starting_stacks = [first_stack, [], []]

function islegal(stacks)
	order_correct = all(issorted, stacks)

	#check if we use the same disk set that we started with

	disks_in_state = sort([disk for stack in stacks for disk in stack])
	disks_complete = disks_in_state == all_disks

	order_correct && disks_complete
end

function iscomplete(stacks)
	last(stacks) == all_disks
end

function move(stacks, source::Int, target::Int)
	#check if the from stack if not empty
	if isempty(stacks[source])
		error("Error: attempted to move disk from empty stack")
	end

	new_stacks = deepcopy(stacks)

	disk = popfirst!(new_stacks[source]) #take disk
	pushfirst!(new_stacks[target], disk) #put on new stack

	return new_stacks
end

function wrong_solution(stacks)::Array{Tuple{Int, Int}}
	return [(1,2), (2,3), (2,1), (1,3)]
end

function move_disks(n, source, target, aux, res)
	if n > 0
		move_disks(n - 1, source, aux, target, res)
		push!(res, (source, target))
		move_disks(n - 1, aux, target, source, res)
	end
end

function solve(stacks)::Array{Tuple{Int, Int}}
	res = []
	n = size(first(stacks), 1)

	move_disks(n, 1, 3, 2, res)

	return res
end

function run_solution(solver::Function, start = starting_stacks)
	moves = solver(deepcopy(start)) #apply the solver

	all_states = Array{Any,1}(undef, length(moves) + 1)
	all_states[1] = starting_stacks

	for (i, m) in enumerate(moves)
		try
			all_states[i + 1] = move(all_states[i], m[1], m[2])
		catch
			all_states[i + 1] = missing
		end
	end

	return all_states
end

run_solution(wrong_solution)

stacks = run_solution(solve)

for stack in stacks
	println(stack)
end

function check_solution(solver::Function, start = starting_stacks)
	try
		#run the solution
		all_states = run_solution(solver, start)

		#check if each state is legal
		all_legal = all(islegal, all_states)

		#check if the final state is is the completed puzzle
		complete = (iscomplete ∘ last)(all_states)

		all_legal && complete
	catch
		#return false if we encountered an error
		return false
	end
end

solved = check_solution(solve)

if solved
	println("Solution is valid for ", num_disks, " disks")
else
	println("Wrong solution")
end

