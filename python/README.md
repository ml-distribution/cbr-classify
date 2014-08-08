My Experimental design comprises of two sets of test cases. The first set containing 5 test cases classified under depth < = 5 category and the second set containing 5 test cases again but falling under the category depth < = 20.
Goal State: makeState (1, 2, 3, 4, 5, 6, 7, 8, 0) 
First Set of test cases - should have solutions with depth <= 5
initialState1 = makeState (2, 0, 3, 1, 5, 6, 4, 7, 8)
initialState2 = makeState (1, 2, 3, 0, 4, 6, 7, 5, 8)
initialState3 = makeState (1, 2, 3, 4, 5, 6, 7, 0, 8)
initialState4 = makeState (1, 0, 3, 5, 2, 6, 4, 7, 8)
initialState5 = makeState (1, 2, 3, 4, 8, 5, 7, 0, 6)

Second Set of test cases - should have solutions with depth <= 20
initialState11 = makeState (0, 5, 3, 2, 1, 6, 4, 7, 8)
initialState12 = makeState (5, 1, 3, 2, 0, 6, 4, 7, 8)
initialState13 = makeState (2, 3, 8, 1, 6, 5, 4, 7, 0)
initialState14 = makeState (1, 2, 3, 5, 0, 6, 4, 7, 8)
initialState15 = makeState (0, 3, 6, 2, 1, 5, 4, 7, 8)

For set 1, the test case used for comparison is as follows:- 
Initial State: makeState (2, 4, 3, 1, 0, 6, 7, 5, 8)
Goal State:  makeState (1, 2, 3, 0, 5, 6, 4, 7, 8)

For set 2. The test case used for comparison is as follows:-
Initial State: makeState (2, 3, 0, 1, 6, 8, 4, 7, 5)
Initial State: makeState (1, 2, 0, 4, 5, 3, 7, 8, 6)
It should be noted that for the above experimental setup, the case base is prepopulated with only the above listed Set 1 and Set 2. For all other scenarios, the case base is prepopulated with the 20 test case given as a part of HW3 sample problems
