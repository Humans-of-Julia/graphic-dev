using Animations
using Javis
using NBodySimulator
using StaticArrays

# Define the bodies
body1 = MassBody(SVector(0.0, 1.0, 0.0), SVector(5.775e-6, 0.0, 0.0), 2.0)
body2 = MassBody(SVector(0.0, -1.0, 0.0), SVector(-5.775e-6, 0.0, 0.0), 2.0)

G = 6.673e-11

system = GravitationalSystem([body1, body2], G)
tspan = (0.0, 1111150.0)

# run the simulation
simulation = NBodySimulation(system, tspan)
sim_result = run_simulation(simulation, saveat = 10)
sim_data = sim_result.solution.u

# extract the data
planet1_pos = [(sim_data[x][1, 1], sim_data[x][2, 1]) for x in 1:length(sim_data)]
planet2_pos = [(sim_data[x][1, 2], sim_data[x][2, 2]) for x in 1:length(sim_data)]

#Convert to Points
planet1_point =
    Point.((200 .* getindex.(planet1_pos, 1)), ((200 .* getindex.(planet1_pos, 2) .- 100)))
planet2_point =
    Point.((200 .* getindex.(planet2_pos, 1)), ((200 .* getindex.(planet2_pos, 2) .+ 100)))

# Start the animation
function ground(args...)
    background("black")
    sethue("white")
end

function planet(p, r, color)
    sethue(color)
    return circle(p, r, :fill)
end


function make_animation()
    nframes = 200

    vid = Video(500, 500)
    Background(1:nframes, ground)

    planet1 = Object(1:nframes, (args...) -> planet(planet1_point[1], 10.0, "red"))
    planet2 = Object(1:nframes, (args...) -> planet(planet2_point[1], 10.0, "blue"))

    planet1_anim = Animation(
        collect(range(0, stop = 1, length = length(planet1_point))),
        planet1_point,
        [linear() for _ in 1:(length(planet1_point) - 1)],
    )

    planet2_anim = Animation(
        collect(range(0, stop = 1, length = length(planet2_point))),
        planet2_point,
        [linear() for _ in 1:(length(planet2_point) - 1)],
    )

    act!(planet1, Action(1:nframes, planet1_anim, translate()))
    act!(planet2, Action(1:nframes, planet2_anim, translate()))

    render(vid; pathname = "two_body.gif")
end

make_animation()
