import time
from pydoc import deque
from heapq import heappush, heappop
from random import choice
goalState = []
base=[]
p1=[]
p1_1=[]
# Uninformed Search - BFS
def uninformedSearch(queue,goalstate,limit,numRuns,choice,p1):

    # List to keep track of visited nodes
    visited = []

    # Get first list of states in queue
    path = deque([queue])

    # cloning path
    temp_path = [queue]

    # If no more states available then return false
    if queue == []:
        print "No Solution Exists"
        return
    elif testProcedure(queue[0],goalstate):
	# Check state is goal state and print output
        outputProcedure(numRuns, queue[0],choice,p1)
        return 
    elif limit == 0:
        print "Limit reached"
        return
    
    q = deque(queue)
                
    while len(q) > 0:     
	# Get first element in queue
        n = q.popleft()
        
        temp_path = path.popleft()
        if n not in visited:
	    # add node to visited nodes
            visited.append(n)
            limit -= 1
            numRuns += 1

	    
            if queue == []:     # check for elements in queue
	        print "No Solution Exists"
                return 
            elif testProcedure(n,goalstate):      # check if reached goal state 
	        outputProcedure(numRuns,temp_path,choice,p1)
                return 
            elif limit == 0:
	        print "Limit reached"
                return
            
            successors = expandProcedure(n)     #find successors of current state
            for succ in successors:
                new_path = temp_path + [succ]
                path.append(new_path)
			
            q.extend(successors)      # Add successors in queue
    print "No Solution Exists"                
    return
        
def testProcedure(queue,goalstate):
    if (queue == goalstate):
        return True
    else:
        return False
     
def outputProcedure(numRuns, path1,choice,p1):
    if choice == "zero":
    	p1.append(path1)
        #print "path being appended is: ",p1
    if choice == "one":
    	print "Total number of runs=", numRuns
    	print "Path Cost=", len(path1)-1
    	p1.append(path1)
	#print "path being appended is: ",p1
    	idx = 0    
    	for i in path1:
        	print "Game State: ", idx
        	idx += 1
        	print (" " if i[0] == 0 else i[0]) , " " , (" " if i[1] == 0 else i[1]) , " " , (" " 			if i[2] == 0 else i[2]) 
        	print (" " if i[3] == 0 else i[3]) , " " , (" " if i[4] == 0 else i[4]) , " " , (" " 			if i[5] == 0 else i[5]) 
        	print (" " if i[6] == 0 else i[6]) , " " , (" " if i[7] == 0 else i[7]) , " " , (" " 			if i[8] == 0 else i[8]), "\n"
	#p1=[]
        
        
# Successor function        
def expandProcedure(state):
    successors = []
    blankPos = 0
    adjacent = []
    # Get position of blank tile
    for i in range(len(state)):
        if state[i] == 0:
            blankPos = i
	
    # Check whether left edge tiles
    if (blankPos % 3 != 2):
        nextPos = blankPos + 1
        adjacent.append(nextPos)

    # Check whether right edge tiles
    if (blankPos % 3 != 0):
        prev = blankPos - 1
        adjacent.append(prev)

    # Check up tile
    if (blankPos > 2):
        up = blankPos - 3
        adjacent.append(up)

    # Check down tile
    if (blankPos < 6):
        down = blankPos + 3
        adjacent.append(down)

    succ = state
    for pos in adjacent:
        succ = list(state)
		
	# Swap tiles and make new state. Add to successor
        if pos >= 0 and pos <= 8:
            temp = succ[blankPos]
            succ[blankPos] = succ[pos]
            succ[pos] = temp
            successors.append(succ)
    return successors
    
# Create state from initial and goal state
def makeState(nw, n, ne, w, c, e, sw, s, se):
    statelist = [nw, n, ne, w, c, e, sw, s, se]
    for i in range(len(statelist)):
	# Replace blank with 0
        if statelist[i] == "blank":
            statelist[i] = 0
    return statelist    

def testUninformedSearch(initialstate, goalstate,limit,choice,p1):
    uninformedSearch ([initialstate], goalstate,limit,0,choice,p1)# The choice parameter is passed in order to avoid printing the computational details for prepopulating the case base
    Add_Path(initialstate,goalstate,p1)
    
def testCaseBasedSearch(initialstate,goalstate_input):
	list_of_similarity_indexes=[]
	list_thresh = []
	list_max_similarity = []
	list_max=[]
	list_tp=[]
	max_el=0
	final_list=[]
	total_similarity = 0
	
	for i in range(0,len(base)):
		tuple_number = i
		initialstatelist=[]
		goalstatelist=[]
		similarity_index_initialstate = check_similarity(initialstate,base[i][0])
		similarity_index_goalstate = check_similarity(goalstate_input,base[i][1])
		print "\n"
		print "Similarity with Tuple number ",i," of Case Base is as follows:-"
		print "--Initial State: ",base[i][0]
		print "--Similarity index for intial state is: ",similarity_index_initialstate
		print "--Goal State: ", base[i][1]
		print "--Similarity index for goal state is: ",similarity_index_goalstate
		list_of_similarity_indexes.append((tuple_number,similarity_index_initialstate,similarity_index_goalstate))
	print "\n"	
	
	for i in range(0,len(list_of_similarity_indexes)):# This loop is to check if an exact set of initial and goal states exists in the case base
		if list_of_similarity_indexes[i][1] == 9 and list_of_similarity_indexes[i][2] == 9:
			base_index = list_of_similarity_indexes[i][0]
			print "Exact match found in case base on tuple number: ",base_index
			retrieval(base_index)
			list_calc = []
			return
	
	for i in range(0,len(list_of_similarity_indexes)): # This loop is to check of an exact initial state exists in the case base but the goal state differs	
		if list_of_similarity_indexes[i][1] == 9 and list_of_similarity_indexes[i][2] >=5:
			base_index = list_of_similarity_indexes[i][0]
			print "Exact Initial State found in case base...only the goal state differs"
			final_list.append(([],base[base_index][1]))
			print "The goal state which seems to be most similar to the given input as per the case base is: ", final_list[0][1]
			return final_list
		
		if list_of_similarity_indexes[i][1] >=5 and list_of_similarity_indexes[i][2] ==9:# This loop is to check of an exact goal state exists in the case base but the initial state differs
			base_index = list_of_similarity_indexes[i][0]
			print "Exact Goal State found in case base...only the initial state differs"
			final_list.append((base[base_index][0],[]))
			print "The initial state which seems to be most similar to the given input as per the case base is: ", final_list[0][0]
			return final_list
			
		if list_of_similarity_indexes[i][1] >=5 and list_of_similarity_indexes[i][2] >=5:#If no exact set of initial and goal states exist in the case base but if some of them are sufficiently similar to the given input
			base_index = list_of_similarity_indexes[i][0]
			total_similarity = list_of_similarity_indexes[i][1]+list_of_similarity_indexes[i][2]
			if total_similarity >=10:
				list_thresh.append((base_index,total_similarity))
			else:
				total_similarity = 0 
	if total_similarity == 0:
		print "No sufficiently similar test case exists in the case base..will have to start from scratch"
		p1=[]
		t1 = time.time()
		testUninformedSearch(initialstate,goalstate_input,200000,"one",p1)
		Add_Path(initialstate,goalstate_input,p1) 
		return

	for i in range(0,len(list_thresh)):
		list_tp.append(list_thresh[i][1]) #Finding the maximum similarity index
	max_el = max(list_tp)

	for i in range(0,len(list_thresh)):
		if list_thresh[i][1]== max_el: 
			list_max.append(list_thresh[i][0])
	
	random_index = choice(list_max) # If there are multiple tuples with the same maximum similarity index then any one of them is chosen at random
	for i in range(0,len(base)):
		if i == random_index:
			final_list.append((base[i][0],base[i][1]))
	print "The set of initial and goal states which seem to be most similar to your input according to the the case base are: ", final_list		
	return final_list		
				
def check_similarity(list_for_comparison, list_from_base):# this function compares each and every tile of the two lists and depending on how many tiles are similar a counter is maintained and ultimately returned
	count=0
	#print "Comparing ",list_for_comparison, " with ", list_from_base 
	for i in range(0,len(list_from_base)):
		if (list_for_comparison[i] == list_from_base[i]):
			count = count + 1
			
	return count

def Add_Path(initial,final,p): #This function appends a new set of initial state,goal state and corresponding path into the case base
	base.append((initial,final,p))
	#print "Current values in case base are: "
	#print base 
	
def generate_test_cases(p1):# prepopulates the case base with the 20 test cases from HW3 sample problem file
	choice="zero"
	#t1 = time.time()
	initialState1 = makeState(2, "blank", 3, 1, 5, 6, 4, 7, 8)
	testUninformedSearch(initialState1, goalState, 200000,choice,p1)
	#t2 = time.time()
    	#print "Time taken for Uninformed Search: ", (t2-t1), " Seconds" 
	p1=[]
	#t1 = time.time()
	initialState2 = makeState(1, 2, 3, "blank", 4, 6, 7, 5, 8)
	testUninformedSearch(initialState2, goalState, 200000,choice,p1)
	#t2 = time.time()
    	#print "Time taken for Uninformed Search: ", (t2-t1), " Seconds" 
	p1=[]
	#t1 = time.time()
	initialState3 = makeState(1, 2, 3, 4, 5, 6, 7, "blank", 8)
	testUninformedSearch(initialState3, goalState, 200000,choice,p1)
	#t2 = time.time()
    	#print "Time taken for Uninformed Search: ", (t2-t1), " Seconds" 
	p1=[]
	#t1 = time.time()
	initialState4 = makeState(1, "blank", 3, 5, 2, 6, 4, 7, 8)
	testUninformedSearch(initialState4, goalState, 200000,choice,p1)
	#t2 = time.time()
    	#print "Time taken for Uninformed Search: ", (t2-t1), " Seconds" 
	p1=[]
	#t1 = time.time()
	initialState5 = makeState(1, 2, 3, 4, 8, 5, 7, "blank", 6)
	testUninformedSearch(initialState5, goalState, 200000,choice,p1)
	#t2 = time.time()
    	#print "Time taken for Uninformed Search: ", (t2-t1), " Seconds" 
	p1=[]	
	initialState6 = makeState(2, 8, 3, 1, "blank", 5, 4, 7, 6)
	testUninformedSearch(initialState6, goalState, 200000,choice,p1)
	p1=[]
	initialState7 = makeState(1, 2, 3, 4, 5, 6, "blank", 7, 8)
	testUninformedSearch(initialState7, goalState, 200000,choice,p1)
	p1=[]
	initialState8 = makeState("blank", 2, 3, 1, 5, 6, 4, 7, 8)
	testUninformedSearch(initialState8, goalState, 200000,choice,p1)
	p1=[]
	initialState9 = makeState(1, 3, "blank", 4, 2, 6, 7, 5, 8)
	testUninformedSearch(initialState9, goalState, 200000,choice,p1)
	p1=[]
	initialState10 = makeState(1, 3, "blank", 4, 2, 5, 7, 8, 6)
	testUninformedSearch(initialState10, goalState, 200000,choice,p1)
	p1=[]
	#t1 = time.time()
	initialState11 = makeState("blank", 5, 3, 2, 1, 6, 4, 7, 8)
	testUninformedSearch(initialState11, goalState, 200000,choice,p1)
	#t2 = time.time()
    	#print "Time taken for Uninformed Search: ", (t2-t1), " Seconds" 
	p1=[]
	t1 = time.time()
	initialState12 = makeState(5, 1, 3, 2, "blank", 6, 4, 7, 8)
	testUninformedSearch(initialState12, goalState, 200000,choice,p1)
	t2 = time.time()
    	#print "Time taken for Uninformed Search: ", (t2-t1), " Seconds" 
	p1=[]
	#t1 = time.time()
	initialState13 = makeState(2, 3, 8, 1, 6, 5, 4, 7, "blank")
	testUninformedSearch(initialState13, goalState, 200000,choice,p1)
	#t2 = time.time()
    	#print "Time taken for Uninformed Search: ", (t2-t1), " Seconds" 
	p1=[]
	#t1 = time.time()
	initialState14 = makeState(1, 2, 3, 5, "blank", 6, 4, 7, 8)
	testUninformedSearch(initialState14, goalState, 200000,choice,p1)
	#t2 = time.time()
    	#print "Time taken for Uninformed Search: ", (t2-t1), " Seconds" 
	p1=[]
	#t1 = time.time()
	initialState15 = makeState("blank", 3, 6, 2, 1, 5, 4, 7, 8)
	testUninformedSearch(initialState15, goalState, 200000,choice,p1)
	#t2 = time.time()
    	#print "Time taken for Uninformed Search: ", (t2-t1), " Seconds" 
	p1=[]
	"""initialState16 = makeState(2, 6, 5, 4, "blank", 3, 7, 1, 8)
	testUninformedSearch(initialState16, goalState, 200000,choice,p1)
	p1=[]
	initialState17 = makeState(3, 6, "blank", 5, 7, 8, 2, 1, 4)
	testUninformedSearch(initialState17, goalState, 200000,choice,p1)
	p1=[]
	initialState18 = makeState(1, 5, "blank", 2, 3, 8, 4, 6, 7)
	testUninformedSearch(initialState18, goalState, 200000,choice,p1)
	p1=[]
	initialState19 = makeState(2, 5, 3, 4, "blank", 8, 6, 1, 7)
	testUninformedSearch(initialState19, goalState, 200000,choice,p1)
	p1=[]
	initialState20 = makeState(3, 8, 5, 1, 6, 7, 4, 2, "blank")
	testUninformedSearch(initialState20, goalState, 200000,choice,p1)
	p1=[]"""
	
def retrieval(base_index):# This function is invoked when an exact match is found in the case base
	print "Initial State of the exact match in case base is: ",base[base_index][0]
	print "Goal State of the exact match in case base is: ",base[base_index][1]
	retrieved_path = []
	print "The retrieved path is as follows:-"
	retrieved_path.append(base[base_index][2])
	print "length of retrieved path is: ",len(retrieved_path[0][0])
	for i in range(0,len(retrieved_path[0][0])):		
		print retrieved_path[0][0][i],"\n"
        	

       
# Main()
if __name__ == "__main__":
    goalState = makeState(1,2,3,4,5,6,7,8,"blank") #This goalState is just for pre-populating the case base initially
    print "Uninformed Search"
    print "Pre-Populating the case base..."
    generate_test_cases(p1)
    print "Case base has been successfully pre-populated and is ready"
    p1=[] 
    p2=[]
    p2_1=[]
    p3=[]
    p3_1=[]
    pfinal=[]
    pfinal1=[]
    pintermediate=[]
    list_calc=[]
    print "\n"
#User Input:-
    x=input("Press 1 to give input test case and 0 to exit : ")
    while(x!=0):
    	print "Enter Initial state input...Enter 0 for blank :-"
    	nw = input("Northwest element : ")
	n = input("North element : ")
	ne = input("Northeast element : ")
	w = input("West element : ")
	c = input("Center element : ")
	e = input("East element : ")
	sw = input("Southwest element : ")
	s = input("South element : ")
	se = input("Southeast element : ")
	initialState = makeState(nw,n,ne,w,c,e,sw,s,se)
	print "\n"
	print "Enter Goal state input...Enter 0 for blank :-"
	nw = input("Northwest element : ")
	n = input("North element : ")
	ne = input("Northeast element : ")
	w = input("West element : ")
	c = input("Center element : ")
	e = input("East element : ")
	sw = input("Southwest element : ")
	s = input("South element : ")
	se = input("Southeast element : ")
	goalState_input = makeState(nw,n,ne,w,c,e,sw,s,se)
	t1 = time.time()
	list_calc.append(testCaseBasedSearch(initialState,goalState_input))
	if list_calc != [None]:		
		if list_calc[0][0][0] != []:
			if list_calc[0][0][1] == []:# if initial state differs but the exact goal state has been found in the case base 
				for i in range(0,len(base)):
					if list_calc[0][0][0] == base[i][0] and goalState_input == base[i][1]:
						pintermediate.append(base[i][2])#retrieving the existing path from case base
			print "Path from new initial state ",initialState," to existing initial state ",list_calc[0][0][0]," is as follows:- "
    			testUninformedSearch(initialState,list_calc[0][0][0],200000,"one",p1)
			p2_1.append(p1) #calculating the path and also removing duplicates
    			for i in range(0,len(p2_1[0][0])-1):
    				p2.append(p2_1[0][0][i])
		p1=[]
		if list_calc[0][0][1] != []:
			if list_calc[0][0][0] == []:
				for i in range(0,len(base)):
					if initialState == base[i][0] and list_calc[0][0][1] == base[i][1]:
						pintermediate.append(base[i][2])
			print "Path from existing goal state ",list_calc[0][0][1]," to existing goal state ",goalState_input," is as follows:- "
    			testUninformedSearch(list_calc[0][0][1],goalState_input,200000,"one",p1)
			p3_1.append(p1)
    			for i in range(1,len(p3_1[0][0])):
    				p3.append(p3_1[0][0][i])
		
		if list_calc[0][0][0] !=[] and list_calc[0][0][1] !=[]:
			for i in range(0,len(base)):
					if list_calc[0][0][0] == base[i][0] and list_calc[0][0][1] == base[i][1]:
						pintermediate.append(base[i][2])
		j=0
		k=0
		print "Summary of the new data added to the case base is as follows:-"		
		print "--New Initial State: ",initialState
		print "--New   Goa   State: ",goalState_input
		print "--Final Path  Cost : ",len(p2)+1+len(pintermediate)+len(p3)+1
		if p2 !=[] and p3 !=[]:
    			pfinal.append(p2+pintermediate+p3)
			print "--Path:- "
			for i in range(0,len(p2)):
				print "[",p2[i][0],"|",p2[i][1],"|",p2[i][2],"]\n"
				print "[",p2[i][3],"|",p2[i][4],"|",p2[i][5],"]\n"
				print "[",p2[i][6],"|",p2[i][7],"|",p2[i][8],"]\n"
				print "\n"
			for i in range(0,len(pintermediate[0][0])):
				print "[",pintermediate[0][0][i][0],"|",pintermediate[0][0][i][1],"|",pintermediate[0][0][i][2],"]\n"
				print "[",pintermediate[0][0][i][3],"|",pintermediate[0][0][i][4],"|",pintermediate[0][0][i][5],"]\n"
				print "[",pintermediate[0][0][i][6],"|",pintermediate[0][0][i][7],"|",pintermediate[0][0][i][8],"]\n"
				print"\n"
				#print pintermediate[0][0][i],"\n"
			for i in range(0,len(p3)):
				print "[",p3[i][0],"|",p3[i][1],"|",p3[i][2],"]\n"
				print "[",p3[i][3],"|",p3[i][4],"|",p3[i][5],"]\n"
				print "[",p3[i][6],"|",p3[i][7],"|",p3[i][8],"]\n"
				print "\n"
		if p2 !=[] and p3 == []:
			pfinal.append(p2+pintermediate)
			print "--Path:- "
			for i in range(0,len(p2)):
				print "[",p2[i][0],"|",p2[i][1],"|",p2[i][2],"]\n"
				print "[",p2[i][3],"|",p2[i][4],"|",p2[i][5],"]\n"
				print "[",p2[i][6],"|",p2[i][7],"|",p2[i][8],"]\n"
				print "\n"
			for i in range(0,len(pintermediate[0][0])):
				print "[",pintermediate[0][0][i][0],"|",pintermediate[0][0][i][1],"|",pintermediate[0][0][i][2],"]\n"
				print "[",pintermediate[0][0][i][3],"|",pintermediate[0][0][i][4],"|",pintermediate[0][0][i][5],"]\n"
				print "[",pintermediate[0][0][i][6],"|",pintermediate[0][0][i][7],"|",pintermediate[0][0][i][8],"]\n"
				print"\n"

		if p2 == [] and p3 !=[]:
			pfinal.append(pintermediate+p3)
			print "--Path:- "
			for i in range(0,len(pintermediate[0][0])):
				print "[",pintermediate[0][0][i][0],"|",pintermediate[0][0][i][1],"|",pintermediate[0][0][i][2],"]\n"
				print "[",pintermediate[0][0][i][3],"|",pintermediate[0][0][i][4],"|",pintermediate[0][0][i][5],"]\n"
				print "[",pintermediate[0][0][i][6],"|",pintermediate[0][0][i][7],"|",pintermediate[0][0][i][8],"]\n"
				print"\n"
			for i in range(0,len(p3)):
				print "[",p3[i][0],"|",p3[i][1],"|",p3[i][2],"]\n"
				print "[",p3[i][3],"|",p3[i][4],"|",p3[i][5],"]\n"
				print "[",p3[i][6],"|",p3[i][7],"|",p3[i][8],"]\n"
				print "\n"
		Add_Path(initialState,goalState_input,pfinal)
	t2 = time.time()
	print "Time taken for Uninformed Search with case-based reasoning: ", (t2-t1), " Seconds" 
	x = input("Press 1 to continue and 0 to exit: ")
	if x == 0:
		break
	else:
		p1=[]		
		p2=[]
    		p2_1=[]
    		p3=[]
    		p3_1=[]
    		pfinal=[]
    		pfinal1=[]
    		pintermediate=[]
    		list_calc=[]
