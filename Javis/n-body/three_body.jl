using Animations
using Colors
using Javis
using NBodySimulator
using StaticArrays

m1 = MassBody(SVector(-0.995492, 0.0, 0.0), SVector(-0.347902, -0.53393, 0.0), 1.0)
m2 = MassBody(SVector(0.995492, 0.0, 0.0), SVector(-0.347902, -0.53393, 0.0), 1.0)
m3 = MassBody(SVector(0.0, 0.0, 0.0), SVector(0.695804, 1.067860, 0.0), 1.0)

G = 1
system = GravitationalSystem([m1, m2, m3], G)


tspan = (0.0, 2pi);
simulation = NBodySimulation(system, tspan)

sim_result = run_simulation(simulation,saveat = 0.01)
sim_data = sim_result.solution.u

# extract the data
planet1_pos = [(sim_data[x][1, 1], sim_data[x][2, 1]) for x in 1:length(sim_data)]
planet2_pos = [(sim_data[x][1, 2], sim_data[x][2, 2]) for x in 1:length(sim_data)]
planet3_pos = [(sim_data[x][1, 3], sim_data[x][2, 3]) for x in 1:length(sim_data)]

# scaling factor
scaling_factor = 210
#Convert to Points
planet1_point = Point.((scaling_factor .* getindex.(planet1_pos, 1)), ((scaling_factor .* getindex.(planet1_pos, 2))))
planet2_point = Point.((scaling_factor .* getindex.(planet2_pos, 1)), ((scaling_factor .* getindex.(planet2_pos, 2))))
planet3_point = Point.((scaling_factor .* getindex.(planet3_pos, 1)), ((scaling_factor .* getindex.(planet3_pos, 2))))

#Julia logo colors
logocolors = Colors.JULIA_LOGO_COLORS
red = logocolors.red
green = logocolors.green
purple = logocolors.purple
blue = logocolors.blue

function ground(args...)
    background("black")
    sethue(blue)
end

function planet(p, r, color)
    sethue(color)
    return circle(p, r, :fill)
end

function make_animation(red, green, purple)
    nframes = 200

    vid = Video(500, 500)
    Background(1:nframes, ground)

    planet1_anim = Animation(
        collect(range(0, stop = 1, length = length(planet1_point))),
        planet1_point,
        linear()
    )

    planet2_anim = Animation(
        collect(range(0, stop = 1, length = length(planet2_point))),
        planet2_point,
        linear()
    )

    planet3_anim = Animation(
        collect(range(0, stop = 1, length = length(planet3_point))),
        planet3_point,
        linear()
    )


    planet1 = Object(1:nframes, (args...) -> planet(O, 20.0, red))
    planet2 = Object(1:nframes, (args...) -> planet(O, 20.0, purple))
    planet3 = Object(1:nframes, (args...) -> planet(O, 20.0, green))

    act!(planet1, Action(1:nframes, planet1_anim, translate()))
    act!(planet2, Action(1:nframes, planet2_anim, translate()))
    act!(planet3, Action(1:nframes, planet3_anim, translate()))

    render(vid; pathname = "three_body.gif")
end

make_animation(red, green, purple)
