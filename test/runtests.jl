using RobustShortestPath, Test

data = [
 1   4  79   31  66  28;
 1   2  59   97  41  93;
 2   4  31   21  50  40;
 2   3  90   52  95  38;
 2   5   9   23  95  59;
 2   6  32   57  73   7;
 3   9  89  100  38  21;
 3   8  66   13   4  72;
 3   6  68   95  58  58;
 3   7  47   12  56  20;
 4   3  14   19  36  84;
 4   9  95   65  88  42;
 4   8  88   13  62  54;
 5   3  44    8  62  53;
 5   6  83   66  30  19;
 6   7  33    3   7   8;
 6   8  37   99  29  46;
 7  11  79   54  23   3;
 7  12  10   37  35  43;
 8   7  95   71  85  56;
 8  10   0   95  16  64;
 8  12  30   38  16   3;
 9  10   5   69  51  71;
 9  11  44   60  60  17;
10  13  79   78  16  59;
10  14  91   59  64  61;
11  14  53   38  84  77;
11  15  80   85  78   6;
11  13  56   23  26  85;
12  15  75   80  31  38;
12  14   1  100  18  40;
13  14  48   28  45  33;
14  15  25   71  33  56;
]


start_node = data[:,1] #first column of data
end_node = data[:,2] #second column of data
p = data[:,3] #third
q = data[:,4] #fourth
c = data[:,5] #fifth
d = data[:,6] #sixth






# Link length vectors for single-uncertain-coefficient robust shortest paths
cc = p.*c
dd = (p+q).*(c+d) - p.*c


# Setting origin and destination nodes
origin = 1
destination = 15
println("Origin=$origin, Destination=$destination")


@testset "Single Coefficient Case" begin
    println("----------------------------------------------------")
    println("Single Coefficient Case")
    # For each Gamma from 0 to 6, obtain the robust shortest path
    known_cost_solution_one = Dict(0 => 6060, 1=> 15024, 2=> 20864, 3=> 26604, 4=> 31293, 5=> 32291)
    for Gamma=0:5
    	robust_path, robust_x, worst_case_cost = get_robust_path(start_node, end_node, cc, dd, Gamma, origin, destination)
    	println("Gamma=$Gamma: Robust Path is $(robust_path') and the worst-case cost is $worst_case_cost.")

        @test worst_case_cost == known_cost_solution_one[Gamma]
    end
end



@testset "Two Coefficient Case" begin
    println("----------------------------------------------------")
    println("Two Coefficient Case")

    for Gamma_u=1:5
        for Gamma_v=1:5
            robust_path, robust_x, worst_case_cost = get_robust_path_two(start_node, end_node, p, q, c, d, Gamma_u, Gamma_v, origin, destination)
            println("(Gamma_u,Gamma_v)=($Gamma_u,$Gamma_v): Robust Path is $(robust_path') and the worst-case cost is $worst_case_cost.")
        end
    end

    test_Gamma_u = 5
    test_Gamma_v = 5
    robust_path, robust_x, worst_case_cost = get_robust_path_two(start_node, end_node, p, q, c, d, test_Gamma_u, test_Gamma_v, origin, destination)

    println(worst_case_cost)
    @test worst_case_cost==32291.0
end
