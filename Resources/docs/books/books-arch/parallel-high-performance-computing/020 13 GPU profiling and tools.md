# 13 GPU profiling and tools

***13 GPU profiling and tools***

This chapter covers

- Available profiling tools for the GPU
- A sample workflow for these tools
- How to use the output from the GPU profiling tools

In this chapter, we will cover the tools and the different workflows that you can use to accelerate your application development. We’ll show you how profiling tools for the GPU can be helpful. In addition, we’ll discuss how to deal with the challenges of using profiling tools when working on a remote HPC cluster. Because the profiling tools continue to change and improve, we’ll focus on the methodology rather than the details of any one tool. The main takeaway of this chapter will be understanding how to create a productive workflow when using the powerful GPU profiling tools.

***13.1 An overview of profiling tools***

Profiling tools allow for quicker optimization, improving hardware utilization, and a better understanding of the application performance and hotspots. We’ll discuss how profiling tools expose bottlenecks and assist you in attaining better hardware usage. The following bulleted list highlights the commonly used tools in GPU profiling. We specifically show the NVIDIA tools for use with their GPUs because these tools have been around the longest. If you have a different vendor’s GPU on your system, substitute their tools in the workflow. Don’t forget about the standard Unix profiling tools such as gprof that we’ll use later in section 13.4.2.

We encourage you to follow along with the examples for this chapter. The accompanying source code is at <http://github.com/EssentialsOfParallelComputing/Chapter13>, which shows examples of installing the software packages for tools from different hardware vendors. There are detailed lists of all the software that can be installed for each vendor. You will probably want to install the tools for the corresponding hardware.

> > > **NOTE** While a tool for another vendor might partially run on your system, its full functionality will be crippled.

- NVIDIA nvidia-smi—When trying to get a quick system profile from the command line, you can use nvidia-smi. As shown and explained in section 9.6.2, NVIDIA SMI (System Management Interface) allows for monitoring and collecting power and temperature during an application run. NVIDIA SMI gives you hardware information along with many other system metrics. The link to the SMI guide and options are in the “Further Explorations” section later in this chapter.

- NVIDIA nvprof—This NVIDIA Visual Profiler command-line tool collects and reports data on GPU performance. The data can also be imported into a visual profiling tool such as the NVIDIA Visual Profiler NVVP or other formats for application performance analysis. It shows performance metrics such as hardware-to-device copies, kernel usage, memory utilization, and many other metrics.

- NVIDIA NVVP—This NVIDIA Visual Profiler tool provides a visual representation of the application kernel performance. NVVP provides a GUI and guided analysis. It queries the same data the nvprof does, but represents the data to the user in a visual way, offering a quick timeline feature not as readily available on nvprof.

- NVIDIA® Nsight™—NSight is an updated version of NVVP that provides for a visual representation of CPU and GPU usage and application performance. Eventually, it may replace NVVP.

- NVIDIA PGPROF—The PGPROF utility originated with the Portland Group compiler. When the Portland Group was acquired by NVIDIA for their Fortran compiler, they merged Portland’s profiler, PGPROF, with the NVIDIA tools.

- CodeXL (originally AMD CodeXL)—This GPUOpen profiler, debugger, and programming development workbench was originally developed by AMD. See the link to the CodeXL website in the “Additional Reading” section later in this chapter.

***13.2 How to select a good workflow***

Before beginning any complicated task, you must select the appropriate workflow. You might either be onsite with excellent connectivity, offsite with a slow home network, or somewhere in between. Each case requires a different workflow. In this section, we’ll discuss four potential and efficient workflows for these different scenarios.

Figure 13.1 provides a visual representation of the four different workflows. Accessibility and connection speed are the determining factors in deciding which method you end up using. You can either run the tools with a graphics interface directly on the system, remotely with a client-server mode, or just avoid the problem by using command-line tools.

**Figure 13.1 There are several different methods of using the profiling tools that give you alternatives for your application development situation.**

When using profiling tools from a remote server, there is often a heavy delay in visualization and graphics interface response. Client-server mode separates the graphics interface so that it runs locally on your system. It then communicates with the server at the remote site to run the commands. This helps keep the interactive response of the graphical tool interface. For example, profiling tools such as NVVP can have a high latency when used on a remote server. Waiting minutes after every mouse click is not a very productive situation. Fortunately, the NVIDIA tools and many of the other tools give you several options to work around this problem. We go into greater detail on the different workflows in the following discussion.

- Method 1: Run directly on the system—When your network connection for your graphics application is fast, this is the preferred method because the storage requirements are pretty large. If you have a fast connection for graphics display, it is the most efficient way to work. But if your display network connection is slow, the response time for the graphics window is painful, and you will want to use one of the remote options. VNC, X2Go, and NoMachine can compress the graphics output and send it instead, sometimes making slower connections workable.

- Method 2: Remote server—This method runs the application with a command-line tool on the GPU system, then the files are transferred automatically to your local system. Firewalls, batch operations of the HPC system, and other network complications can make this method difficult or impossible to set up.

- Method 3: Profile file download—This method runs nvprof on an HPC site and downloads the files to your local computer. In this method, you manually transfer files to your local computer using secure copy (scp) or some other utility and then work on your local machine. When trying to profile multiple applications, it can be easier to take the raw data in a csv format and combine it into a single dataframe. Though this method may no longer be usable by the conventional profiling tools, you can do your own detailed analysis on the server or locally.

- Method 4: Develop locally—One of the great things about today’s HPC hardware is that you often have similar hardware that you can use to develop an application locally. You might have a GPU from the same vendor but not as powerful as the GPU in the HPC system. You can optimize your application with the expectation that everything will be faster on the big system. You might also be able to develop your code on the CPU with some of the languages where debugging is easier.

The important thing to realize is that even if you are not on a fast connection to a computing site, you have some options when using development tools. Whichever method you use to do your porting and performance analysis, you should ensure that the versions of the software you use match. This is particularly important for CUDA and the NVIDIA nvprof and NVVP tools.

***13.3 Example problem: Shallow water simulation***

In this section, we’ll work with a realistic example to show the code porting process and the use of some available tools. We’ll use the problem from figure 1.9, where a volcanic eruption or earthquake might cause a tsunami to propagate outward. Tsunamis can travel thousands of miles across oceans with just a few feet of height, but when these reach the shore, they can be hundreds of meters high. These types of simulations are usually done after the event because of the time required to set up and run the problem. We’d prefer to simulate it in real time so that we can provide warnings to those who might be affected. Speeding up the simulation by running it on a GPU might provide this capability.

We’ll first walk through the physics that occurs in this scenario then translate that into equations to numerically simulate the problem. The specific scenario we want to represent is the breaking off of a large mass of an island or other land mass, which falls into the ocean as figure 13.2 illustrates. This event actually happened with Anak Krakatau (“Child of Krakatau”) in December, 2018.

**Figure 13.2 The tsunami wave that occurred at Anak Krakatau on December 22, 2018, was caused by a sediment slide from the volcanic island.**

For the December event, the landslide volume on the west flank of the Krakatau island was about 0.2 cubic km. This was smaller than earlier risk projections estimated. Additionally, wave heights were estimated to be over 100 meters. With the short distance from the source to the shore, there was little warning for those in the area, and with over 400 deaths, the event garnered world-wide news coverage.

Scientists performed many simulations prior to the event and even more afterward. You can view some of the visualizations and an analysis of the event at [http:// mng.bz/4Mqw](http://mng.bz/4Mqw). How were the simulations done? The basic physics required is only a small step in complexity from the stencil calculations that we have looked at throughout this book. A full-fledged simulation code might have a lot more sophisticated bells and whistles, but we can go a long way with simple physics. So let’s take a look at the required physics behind the simulations.

The mathematical equations for the tsunami are relatively simple. These are conservation of mass and conservation of momentum. The latter is basically Newton’s first law of motion: “An object at rest stays at rest and an object in motion stays in motion.” The momentum equation uses the second law of motion, “Force is equal to the change in momentum.” For the conservation of the mass equation, we basically have that the change in mass for a computational cell over a small increment in time is equal to the sum of the mass crossing the cell boundaries as shown here:

Where  is the change in mass relative to time, and  and  are the mass fluxes (velocity \* mass) across the x- and y-faces. Further, because water is incompressible, the density of water can be treated as constant. The mass of a cell is the volume \* density. If we have cells that are all 1 meter × 1 meter, the volume is height × 1 meter × 1 meter. Putting this all together, everything is constant except for height, so we can replace mass with the height variable:

Mass = Volume · Density = Height · 1 Meter · 1 Meter · Density = Constant · Height

Also using u = v_(x) and v = v_(y), we now get the standard form of the conservation law for the shallow water equations:

The conservation of momentum is similar but with momentum (mom) replacing the mass or height. We only show the x terms to fit the equation on the page like this:

The additional term of 1/2 gh2 is due to the work done on the system by gravity. According to Newton’s second law, the external force creates additional momentum (F = ma). We’ll look at how this term comes about with and without calculus. First, the acceleration in this case is gravity, and it causes a force acting on the column of water as figure 13.3 shows. Each additional meter of water height creates what is known as hydrostatic pressure, resulting in a higher pressure along the whole column of water. With calculus, we would integrate the pressure along the column to get the momentum created. This integration over the elevation (z) from 0 to the wave height (h) would be

  

**Figure 13.3 The force of gravity on the column of water creates flow and momentum.**

**Figure 13.4 The hydrostatic pressure caused by the force of gravity is a linear function of depth.**

There is also a much simpler derivation. In this case, the pressure is a linear function (figure 13.4). If we look at the height midpoint then apply the pressure difference at the height midpoint to the whole column, we can get the same solution. What we are doing is summing all of the pressure forces under the curve. The mathematical terminology for this is to integrate the function or perform a Riemann sum where you break the area under a curve into columns then add these. But this is all overkill. The area under the curve is a triangle, and we can use the area of a triangle or A = 1/2 bh.

Our resulting set of equations is

If you are observant, you will notice cross-terms of the momentum fluxes for the y -momentum in the x -momentum equation and x-momentum in the y-momentum equation. In the conservation of x -momentum, the third term has x-momentum (hu) moving across the y -face with the y-velocity (v). You can describe this as the advection, or flux, of the x-momentum with the velocity in the y-direction across the top and bottom faces of the computational cell. The flux of the x-momentum (hu) across the x-faces with the velocity u is in the second term as hu².

We also see that the newly created momentum is split across the two momentum equations with the new x-momentum in the x-momentum equation and the y-momentum in the y-momentum equation. These equations are then implemented as three stencil operations in our shallow water code, where for simplicity, we use H = h, U = hu, and V = hv. Now we have a simple scientific application that we can use for our demonstrations.

We have one more implementation detail. We use a numerical method that estimates the properties such as mass and momentum at the faces of each cell halfway through the timestep. We then use these estimates to calculate the amount of mass and momentum that moves into the cell during the timestep. This gives us a little more accuracy for the numerical solution.

Congratulations if you have worked your way through this discussion and gained some understanding. Now you have seen how we take the simple laws of physics and create a scientific application from those. You should always strive to understand the underlying physics and numerical method rather than treat the code as a set of loops.

***13.4 A sample of a profiling workflow***

Next, we reach the profiling step for the shallow water application. For this, we created a shallow water application based on the mathematical and physical equations presented in section 13.3. In many ways, the code is just three stencil calculations for the mass and two momentum equations. We have worked with a single, simple stencil equation since chapter 1, and the example code is included in [https://github .com/EssentialsofParallelComputing/Chapter13](https://github.com/EssentialsofParallelComputing/Chapter13).

***13.4.1 Run the shallow water application***

In this section, we show you how to run the shallow water code. We’ll use the code to step through a sample workflow for porting your code to the GPU. First, some notes about the platforms:

- macOS—NVIDIA warns that CUDA 10.2 may be the last release to support macOS and only supports it up through macOS v10.13. As a result, NVVP is only supported through macOS v10.13. It sort of works with v10.14 but fails completely on v10.15 (Catalina). We suggest using VirtualBox [https://www .virtualbox.org](https://www.virtualbox.org) as a free virtual machine to try out the tools on Mac systems. We have also supplied a Docker container for macOS.

- Windows—NVIDIA still supports Microsoft Windows natively, but you can also use VirtualBox or Docker containers on Windows if you prefer.

- Linux—A direct installation on most Linux systems should work.

If you have a GPU on your local system, you can use the local workflow. If not, you will probably be running remotely on a compute cluster and transferring the files back for analysis.

If you want to use the graphics, you will need to install some additional packages. On an Ubuntu system, you can do this with the following commands. The first command is for installing OpenGL and freeglut for real-time graphics. The second is for installing ImageMagick® to handle the graphics file output that we can use for graphics stills. The graphics snapshots can also be converted into movies. The README .graphics file in the GitHub directory has more information on the graphics formats and the scripts in the examples that accompany this chapter.

> `sudo apt-get install libglu1-mesa-dev freeglut3-dev mesa-common-dev -y`  
> `sudo apt install cmake imagemagick libmagickwand-dev`

We have found that real-time graphics can accelerate code development and debugging, so we included a sample of how to use them in the example code accompanying this chapter. For example, the real-time graphics output uses OpenGL to display the height of the water in the mesh, giving you immediate visual feedback. The real-time graphics code can also be easily extended to respond to keyboard and mouse interactions within the real-time graphics window.

This example is coded with OpenACC, so it is best to use the PGI compiler. A limited subset of the examples works with the GCC compiler due to its still-developing support of OpenACC. Compiling the example code is straightforward. We just use CMake and make.

1.  To build the makefile, type

    > `mkdir build && cd build`  
    > `cmake .. `

2.  To turn on the graphics, type

    > `cmake -DENABLE_GRAPHICS=1`

3.  Set the graphics file format with

    > `export GRAPHICS_TYPE=JPEG`  
    > `make`

4.  Then run the serial code with `./ShallowWater`.

If you cannot get the graphics output to work, the program will run fine without it. But if you get it set up correctly, the real-time graphics output from the code displays a graphics window like that shown in figure 13.5. The graphics are updated every 100 iterations. The figure here shows a smaller mesh than the hard-coded size in the sample code. The lines represent the computational cells with the wave height higher on the left. The wave travels to the right with the height, decreasing as it moves. The wave crosses the computational domain and reflects off the right face. Then it travels back and forth across the mesh. In a real calculation, there would be objects (such as shorelines) in the mesh.

**Figure 13.5 Real-time graphics output from the shallow water application. The red stripes on the left indicate the beginning of the wave, where the landslide enters the water. The wave progresses to the right as it cross the ocean: orange, yellow, green, and blue. If you’re reading this in black and white, the left shaded region corresponds to the red, and the far right shaded region corresponds to the blue. The lines are the outlines of the computational cells.**

If you have a system that can run OpenACC, the executables ShallowWater_par1 through ShallowWater_par4 will also be built. You can use these for the profiling exercises that follow.

***13.4.2 Profile the CPU code to develop a plan of action***

We described the parallel development cycle back in chapter 2 as

1.  Profile

2.  Plan

3.  Implement

4.  Commit

The first step is to profile our application. For most applications, we recommend using a high-level profiler such as the Cachegrind tool we introduced in section 3.3.1. Cachegrind shows the most time-consuming paths through the code and displays the results in an easy-to-interpret visual representation. However, for a simple program like the shallow water application, function-level profilers like Cachegrind are not effective. Cachegrind shows that 100% of the time is spent in the main function, which doesn’t help us much. We need a line-by-line profiler for this particular situation. For this purpose, we draw upon the most well-known profiler on Unix systems—gprof. Later, when we have code that runs on the GPU, we will use the NVIDIA NVVP profiling tool to get the performance statistics. To get started, we just need a simple tool to profile an application running on the CPU.

> **Example: Profiling with gprof**

1.  Edit CMakeLists.txt by adding the `-pg` flag to the compiler flags (diff output shows the original line in the CMakeLists with a `-` symbol and the new line with a `+` symbol):

    > `-set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -O3")`  
    > `+set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -g -O3 -pg")`

2.  Edit ShallowWater.c and increase the mesh size:

    > `-  int      nx = 500, ny = 200;`  
    > `+  int      nx = 5000, ny = 2000;`

3.  Rebuild the ShallowWater executable by typing `make`.

4.  Run the ShallowWater executable by typing `./ShallowWater`. You should get an output file called gmon.out.

5.  Run the post-processing step by typing `gprof -l -pg ./ShallowWater`.

> The output from gprof shows the loops that take the most time in the shallow water application (see the following figure).

>   

> **The output from gprof. The loop at line 207 takes the most time and would make a good starting point for porting to the GPU.**

> We look up the loops for each of the line numbers in the profiling output in the figure and find that these correspond to the following operations:

- `ShallowWater.c:207` (second pass loop)

- `ShallowWater.c:190` (y-face pass)

- `ShallowWater.c:172` (x-face pass)

- `ShallowWater.c:160` (timestep calculation)

> This tells us that we should concentrate our initial efforts on the computation of the second pass at the end of the main computation loop and work our way towards the top of the loop. There is a tendency to try and do everything all at once, but the safer approach is to work loop-by-loop and make sure the result is still correct. By focusing on the most expensive loops first, some performance improvement will be achieved earlier.

***13.4.3 Add OpenACC compute directives to begin the implementation step***

Now that we have profiled the application and developed a plan, the next step in the parallel development cycle is to begin the implementation of the plan. In this step, we begin the eagerly awaited modification of the code.

The implementation starts with porting the code to the GPU by moving the computation loop. We follow the same procedure used in section 11.2.2 to port the code to the GPU. The computations are moved by inserting the `acc parallel loop` pragma in front of every loop as shown on line 95 in the following listing.

**Listing 13.1 Adding a loop directive**

> `OpenACC/ShallowWater/ShallowWater_par1.c`  
> `95 #pragma acc parallel loop`  
> `96       for(int j=1;j<=ny;j++){`  
> `97         H[j][0]=H[j][1];`  
> `98         U[j][0]=-U[j][1];`  
> `99         V[j][0]=V[j][1];`  
> `100         H[j][nx+1]=H[j][nx];`  
> `101         U[j][nx+1]=-U[j][nx];`  
> `102         V[j][nx+1]=V[j][nx];`  
> `103       }`

We also need to replace the pointer swap on line 191 at the end of the loop with a data copy. This is not ideal because it introduces more data movement and is slower than a pointer swap. That being said, doing a pointer swap in OpenACC is tricky because the pointers on the host and device have to be switched simultaneously.

**Listing 13.2 Replacing the pointer swap with a copy**

> `OpenACC/ShallowWater/ShallowWater_par1.c`  
> `  189       // Need to replace swap with copy                          `  
> `  190 #pragma acc parallel loop                         `  
> `  191       for(int j=1;j<=ny;j++){                         `  
> `  192         for(int i=1;i<=nx;i++){`  
> `  193            H[j][i] = Hnew[j][i];`  
> `  194            U[j][i] = Unew[j][i];`  
> `  195            V[j][i] = Vnew[j][i];`  
> `  196         }`  
> `  197       }`

You will get better feedback of the performance of your application from a visual representation. At each step of the process, we run the NVVP profiling tool to get the graphical output of the performance trace.

> **Example: Getting a visual profile of your performance with the NVIDIA Visual Profiler (NVVP)**

> To acquire a visual performance timeline, we run the code with:

> `nvprof --export-profile ShallowWater_par1_timeline.prof ./ShallowWater_par1`

> Using the `nvprof` command saves a profiling timeline within the running directory:

> `nvvp ShallowWater_par1_timeline.prof`

> The `nvvp` command then imports the profile into the NVIDIA Visual Profiler suite with the graphical output shown in the following figure. You can copy the profile back to your local machine in between the two steps and view it locally if you like.

> We’ll first look at the visual profile to get a quick color-coded feel for the relative performance of our memory copies and computational kernels. This is the timeline shown at the top of the visual profiler window. At this point, pay particular attention to the lines MemCpy (HtoD) and MemCpy (DtoH), where the data transfer from the host to the device and the device to host are displayed. The guided analysis and OpenACC details panes that are at the bottom of this window are discussed in section 13.4.5.

>   

> **The NVIDIA NVVP profiler output shows a timeline view of one computational cycle. You can see the the device-to-hardware memory copies and vice versa. On the highlighted line, the output also shows compute regions.**

> If your network connection doesn’t allow either using the graphical tool directly or transferring the profile data to your computer, you can always fall back to using nvprof in its text-based mode. You can get the same information from the text-based output, but there are always some insights that are clearer with the visual representation.

Figure 13.6 shows the ability to zoom into specific kernels to better identify performance metrics within certain compute cycles. Specifically, we zoomed into line 95 from listing 13.1 to show individual memory copies.

**Figure 13.6 With NVIDIA’s NVVP, you can zoom into specific copies in the timeline view. Here, you can see a zoomed in version of individual memory copies within each cycle. This allows you to see what lines these are on to help you easily refer back to the application.**

***13.4.4 Add data movement directives***

The next step in porting the code to the GPU is the addition of data movement directives. This allows us to further improve the application performance by eliminating expensive memory copies. In this section, we will show you how it’s done.

The Visual Profiler, NVVP, helps us to see where we need to focus our efforts. Start by looking for the large MemCpy time blocks and eliminating these one-by-one. As you remove the data transfer costs, your code will start to show speedups, recovering the performance lost during the application of compute directives in section 13.4.4.

In listing 13.3, we show an example of the data movement directives that we added. At the start of the data section, we use the `acc enter data create` directive to start a dynamic data region. The data will then exist on the device until we encounter an `acc exit data directive`. For each loop, we add the `present` clause to tell the compiler the data is already on the device. Refer to the example code for the chapter 13 in the file OpenACC/ShallowWater/ShallowWater_par2.c for all the changes made to control the data movement.

**Listing 13.3 Data movement directives**

> `OpenACC/ShallowWater/ShallowWater_par2.c`  
> `51 #pragma acc enter data create( \`  
> `52         H[:ny+2][:nx+2],    U[:ny+2][:nx+2],    V[:ny+2][:nx+2], \`  
> `53         Hx[:ny][:nx+1],     Ux[:ny][:nx+1],     Vx[:ny][:nx+1],  \`  
> `54         Hy[:ny+1][:nx],     Uy[:ny+1][:nx],     Vy[:ny+1][:nx],  \`  
> `55         Hnew[:ny+2][:nx+2], Unew[:ny+2][:nx+2], Vnew[:ny+2][:nx+2])`  
> `   <...>`  
> `59   #pragma acc parallel loop present( \`  
> `60         H[:ny+2][:nx+2], U[:ny+2][:nx+2], V[:ny+2][:nx+2])`

Applying the data movement directives from listing 13.3 and rerunning the profiler gives us the new performance results in figure 13.7, where you can see the reduction of data movement. By reducing the data transfer time, the overall run time of the application is much faster. In a larger application, you should continue looking for other data transfer operations that you can then eliminate to speed up the code even more.

**Figure 13.7 This timeline from NVIDIA’s Visual Profiler NVVP shows four iterations of the computation but now with data movement optimizations. What is interesting in this figure is not so much what you can see, but what is not there. The data movement that occurred in the previous figure is sharply reduced or no longer exists.**

***13.4.5 Guided analysis can give you some suggested improvements***

For further insight, NVVP provides a guided analysis feature (figure 13.8). In this section, we’ll discuss how to use this feature.

You must judge the suggestions from the guided analysis based on your knowledge of your application. In our example, we have few data transfers, so we will not be able to get memory copy and compute overlap mentioned in the top suggestion of Low Memcpy/Compute Overlap in figure 13.8. This is true of most of the other suggestions. For example, for low kernel concurrency, we only have one kernel, so we can’t have concurrency. Though our application is small and may not need these extra optimizations, these are good to note as they can be useful for larger applications.

**Figure 13.8 NVVP provides a guided analysis section as well. Here, the user can acquire insight for further optimizations. Note that the highlighted region shows low compute utilization.**

Additionally, figure 13.8 shows low compute utilization for our application run. This is not unusual. This low GPU utilization is more indicative of the huge compute power available on the GPU and how much more it can do. To briefly go back to the performance measurements and analysis of our mixbench performance tool (section 9.3.4), we have a bandwidth-limited kernel so we will, at best, use 1-2% of the GPU’s floating-point capability. In light of this, 0.1% compute utilization isn’t so bad.

Another feature of the NVVP tool is an OpenACC Details window that gives the timings for each operation. One of the best ways to use this is by acquiring the before and after timings as figure 13.9 shows. The side-by-side comparisons give you a concrete measurement of improvement from the data movement directives.

**Figure 13.9 NVVP’s OpenACC Details window shows information on each OpenACC kernel and the cost of each operation. We can see the cost of the data transfer in the left window for version 1 of the code versus the time for the optimized data motion in version 2 on the right.**

With the OpenACC Details window opened, you’ll note that the line numbers move within the profile. If we look at line 166 in the ShallowWater_par1 listing (on the left in figure 13.10), it takes 4.8% of the run time. The breakdown of the operations shows that a lot of that time is due to data transfer costs. The corresponding line of code in the ShallowWater_par2 listing is 181 (on the right in figure 13.10) and has the addition of the `present` data clause. We can see that the time for line 181 is only 0.81% and that this is largely due to the elimination of the data transfer costs. The compute construct takes about the same time in both cases at 0.16 ms as shown in the line labeled acc_compute_construct just below the highlighted line.

**Figure 13.10 Side-by-side code comparison showing that line 166 in version 1 of the ShallowWater code is now line 181, which has the additional** **`present`** **clause.**

***13.4.6 The NVIDIA Nsight suite of tools can be a powerful development aid***

NVIDIA is replacing their Visual Profiler tools (NVVP and nvprof) with the Nsight™ tool suite. The tool suite is anchored by two integrated development environments (IDEs):

1.  Nsight Visual Studio Edition supports CUDA and OpenCL development in the Microsoft Visual Studio IDE.

2.  Nsight Eclipse Edition adds the CUDA language to the popular open source Eclipse IDE.

Figure 13.11 shows our shallow water application in the Nsight Eclipse Edition development tool.

**Figure 13.11 The NVIDIA Nsight Eclipse Edition application is a code development tool. This window in the tool shows the ShallowWater_par1 application.**

The Nsight suite of tools also has single function components that can be downloaded by registered NVIDIA developers. These profilers incorporate the functionality from the NVIDIA Visual Profiler and add additional capabilities. The two components are

- Nsight Systems, a system-level performance tool, looks at overall data movement and computation.

- Nsight Compute, a performance tool, gives a detailed view of GPU kernel performance.

***13.4.7 CodeXL for the AMD GPU ecosystem***

AMD also has code development and performance analysis capabilities in their CodeXL suite of tools. As figure 13.12 shows, the application development tool is a full-featured code workbench. CodeXL also includes a profiling component (in the Profile menu) that helps with optimizing code for the AMD GPU.

**Figure 13.12 The CodeXL development tool supports compiling, running, debugging, and profiling.**

These new tools from NVIDIA and AMD are still being rolled out. The availability of full-featured tools, including debuggers and profilers, will be a tremendous boost for GPU code development.

***13.5 Don’t get lost in the swamp: Focus on the important metrics***

As with many profiling and performance measurement tools, the amount of information is initially overwhelming. You should focus on the most important metrics that you can gather from hardware counters and other measurement tools. In recent processors, the number of hardware counters has steadily grown, giving you insight into many aspects of processor performance that were previously hidden. We suggest the following three aspects as the most critical: occupancy, issue efficiency, and memory bandwidth.

***13.5.1 Occupancy: Is there enough work?***

The concept of occupancy is often mentioned as the top concern for GPUs. We first discussed this measure in section 10.3. For good GPU performance, we need enough work to keep compute units (CUs) busy. In addition, we need alternate work to cover stalls when workgroups hit memory-load waits (figure 13.13). As a reminder, CUs in OpenCL terminology are called streaming multiprocessors (SMs) in CUDA. The actual achieved occupancy is reported by the measurement counters. If you encounter low occupancy measures, you can modify the workgroup size and resource usage in the kernels to try and improve this factor. A higher occupancy is not always better. The occupancy just needs to be high enough so that there is alternate work for the CUs.

**Figure 13.13 GPUs have a lot of compute units (CUs), also called streaming multiprocessors (SMs). We need to create a lot of work to keep the CUs busy, with enough extra work for handling stalls.**

***13.5.2 Issue efficiency: Are your warps on break too often?***

Issue efficiency is the measurement of the instructions issued per cycle versus the maximum possible per cycle. To be able to issue an instruction, each CU scheduler must have an eligible wavefront, or warp, ready for execution. An eligible wavefront is an active wavefront that is not stalled. In some sense, it is an important result from having high enough occupancy so that there are lots of active wavefronts. The instructions can be floating point, integer or memory operations. Poorly written kernels with lots of stalls cause low-issue efficiency even if the occupancy is high. There are a variety of reasons for kernels to encounter stalls. There are also counters that can identify particular reasons for stalls. Some of the possibilities are

- Memory dependency—Waiting on a memory load or store

- Execution dependency—Waiting on a previous instruction to complete

- Synchronization—Blocked warp due to a synchronization call

- Memory throttle—Large number of outstanding memory operations

- Constant miss—Miss in the constants cache

- Texture busy—Fully utilized texture hardware

- Pipeline busy—Compute resources not available

***13.5.3 Achieved bandwidth: It always comes down to bandwidth***

Bandwidth is an important metric to understand because most applications are bandwidth limited. The best starting point is to look at the bandwidth measure. There are many memory counters available, allowing you to go as deep as you want. Comparing your achieved bandwidth measurements to the theoretical and measured bandwidth performance for your architecture from sections 9.3.1 through 9.3.3 can give you an estimate on how well your application is doing. You can use the memory measurements to determine whether it would be helpful to coalesce memory loads, to store values in the local memory (scratchpad), or to restructure code to reuse data values.

***13.6 Containers and virtual machines provide alternate workflows***

You are on a flight from somewhere to nowhere and just want to get some of your GPU code working. The latest software release doesn’t work on your company-issued laptop. The workaround is to use a container or a virtual machine (VM) to run a different operating system or a different compiler version.

***13.6.1 Docker containers as a workaround***

Each of our chapters has an example Dockerfile and instructions for its use. The Dockerfile contains the commands to build a basic OS and then to install the necessary software that it needs.

> **Example: Building a Docker image with the supplied Dockerfile**

> The top-level directory for most chapters has a Dockerfile. In the directory for the chapter you are interested in, run the Docker `build` command and create a Docker container using the `-t` option to name it. In this example, we build the chapter 2 Docker container and name it `chapter2`:

> `docker build -t essentialsofparallelcomputing/chapter2 .`

> Now run the Docker container with the following command:

> `docker run -it --entrypoint /bin/bash essentialsofparallelcomputing/chapter2`

> Alternatively, use

> `./docker_run.sh`

> Some chapters have both a text-based and a graphics-based Dockerfile. To enable the text-based file, remove the Dockerfile and link in the text-based version with this command:

> `ln -s Dockerfile.Ubuntu20.04 Dockerfile`

 

A Docker container is useful for dealing with software that does not work on your operating system. For example, for software that only runs on Linux, you can install a container on your Mac or Windows laptop that runs Ubuntu 20.0.4. Using a container works well for text-based, command-line software.

Containers also limit access to hardware devices such as GPUs. One option is to run the device kernels on the CPU for the GPU languages that have that capability. Doing this, we can at least test our software. If that is not enough for our needs, we can tackle some additional steps to try and get the graphics and GPU computation working. We’ll start by looking at getting the graphics working. Running a graphical interface from a Docker build takes a little more effort.

> **Example: Running the Docker image with a GUI on macOS**

> Mac laptops do not have an X Window client built into their standard software. Therefore, you need to install an X Window client on your Mac if you have not done this already. The XQuartz package is an open source version of the original X Window that was included on older versions of macOS. You can install it with the brew package manager like this:

> `brew cask install xQuartz`

> Now start XQuartz and look for the XQuartz menu bar at the top of the screen. If you don’t see it, you might need to also start a sample X Window application such as xterm by using a right-click on the XQuartz icon. Then

1.  Select the XQuartz menu bar and then the Preferences option

2.  Go to the Security tab and select Allow Connections from Network Clients

3.  Reboot your system to apply the settings.

4.  Start XQuartz again

For chapters that require a GUI for tools or plots, the instructions are a little different. We use the Virtual Network Computing (VNC) software to enable the graphics capabilities through a web interface and VNC client viewers. You must use the docker_run.sh script to start the VNC server, then you need to start a VNC client on your local system. You can use one of a variety of VNC client packages, or you can open the graphics file through some browsers with the following in your browser toolbar site name:

> `http:/ /localhost:6080/vnc.html?resize=downscale&autoconnect=1&password=`  
> `  <password>"`

To test an application with a graphical interface such as NVVP, type `nvvp`. Or you might want to test the graphics with a simple X Window application such as xclock or xterm. We can also try to get access to the GPUs for computation. Access to the GPUs can be obtained by using the `—gpus` option or the older `—device=/dev/<device name>`. The option is a relatively new addition to Docker and, currently, is only implemented for NVIDIA GPUs.

> **Example: Accessing GPUs for computational work**

> To access a GPU for computation, add the `—gpus` option with an integer argument for the number of GPUs (gpus) to make available or `all` for all of the GPUs:

> `docker run -it --gpus all --entrypoint /bin/bash chapter13`

> For Intel GPUs, you can try

> `docker run -it --device=/dev/dri --entrypoint /bin/bash chapter13`

Most of the chapters have prebuilt Docker containers. You can access the containers for each chapter at <https://hub.docker.com/u/essentialsofparallelcomputing>. You can retrieve the container for a chapter with the following command:

> `docker run -p 4000:80 -it --entrypoint /bin/bash essentialsofparallelcomputing/chapter2`

There is also a prebuilt Docker container from NVIDIA that you can use as a starting point for your own Docker images. Visit the site at [https://github.com/NVIDIA/ nvidia-docker](https://github.com/NVIDIA/nvidia-docker) for up-to-date instructions. There is another site at NVIDIA with substantial container varieties at <https://ngc.nvidia.com/catalog/containers>. For ROCm, there are extensive instructions on Docker containers at [https://github.com/Rade onOpenCompute/ROCm-docker](https://github.com/RadeonOpenCompute/ROCm-docker). And Intel has a site for how to set up their oneAPI software in containers at <https://github.com/intel/oneapi-containers>. Some of their base containers are large and require a good internet connection.

The PGI compiler is important for OpenACC code development and some other GPU code development challenges as well. If you need the PGI compiler for your work, the container site for PGI compilers is at [https://ngc.nvidia.com/catalog/containers/ hpc:pgi-compilers](https://ngc.nvidia.com/catalog/containers/hpc:pgi-compilers). As you can see from the sites mentioned here, there are many resources for creating work environments with Docker containers. But this is also a rapidly evolving capability.

***13.6.2 Virtual machines using VirtualBox***

Using a virtual machine (VM) allows the user to create a guest OS within their own computer. The normal operating system is called a host, and the VM is called the guest. You can have more than one VM running as a guest. VMs use a more restrictive environment for the guest operating system than exists in the container implementations. Often, it is easier to set up GUIs in comparison to containers. Unfortunately, access to the GPU for computation is difficult or impossible. You might find VMs useful for GPU languages that have an option supporting computation on the host CPU processor.

Let’s look at the process of setting up an Ubuntu guest operating system in VirtualBox. This example sets up the shallow water example running on the CPU with the PGI compiler in VirtualBox with graphics.

> **Example: Setting up an Ubuntu guest OS in VirtualBox**

> To set up your system for VirtualBox

1.  Download VirtualBox for your system and install

2.  Download the Ubuntu desktop and save it to your local disk

    > `[ubuntu-20.04-desktop-amd64.iso]`

3.  Download the VBoxGuestAdditions.iso file, which may already be included in the VirtualBox download

> Next, we set up the Ubuntu guest system. An automated script, autovirtualbox.sh, is included in the examples for this chapter to automate setting up the Ubuntu guest system in VirtualBox at <https://github.com/EssentialsOfParallelComputing/Chapter13.git>. Most of the other chapters have similar scripts. To set up the Ubuntu guest system, follow this process:

1.  Start VirtualBox and click New

2.  Type in a name (chapter13, for example)

3.  Select Linux and then Ubuntu 64-bit

4.  Select the amount of memory (8192, for example)

5.  Create a virtual hard disk

6.  Select VDI VirtualBox Disk Image

7.  Select Fixed Size Disk

8.  Select 50 GB

> Your new virtual machine should now be added to the list.

Now we are ready to install Ubuntu. The process is the same as setting up an Ubuntu system on your desktop.

> **Example: Installing Ubuntu**

> To install Ubuntu, follow these steps:

1.  Start the Ubuntu VM by clicking the green start arrow

2.  Select the iso file saved earlier by typing to ubuntu-20.04-desktop-amd64.iso from the options presented

3.  Select Install Ubuntu

4.  Select your keyboard and click Continue

5.  Select Minimal Install, download updates, and install third-party software, then click Continue

6.  Select Erase Disk and install Ubuntu and then click Install and select a time zone

7.  Type the following into the text boxes: your name (chapter13, for example), your computer's name (chapter13-virtualbox), username (chapter13), and password (chapter13)

8.  Select Require My Password to Log In and then select Continue

> Time to get some coffee. When the installation is complete, restart your computer and follow these steps:

1.  Sign back in

2.  Click through What’s New

3.  Select the dots at bottom left and start a terminal

4.  Edit Sudo Authorized Users configuration file with

    > `sudo -i`  
    > `visudo`

> and add the following in any blank line, `%vboxsf ALL=(ALL) ALL`, then exit

> You may need to wait for updates or reboot and sign back in. Once logged back in install basic build tools with `sudo apt install build-essential dkms git -y`. Then

1.  Make the VirtualBox window active and select the Devices pull-down menu from the window’s menus at top of screen

2.  Set the Shared Clipboard option to Bidirectional

3.  Set the Drag and Drop option to Bidirectional

4.  Install the guest additions by selecting the menu option virtualbox-guest-additions-iso

5.  Remove the optical disk: from the desktop, right-click and eject the device or in the VirtualBox window, select Devices \> Optical Disk and remove the disk from the virtual drive

6.  Reboot and test by copying and pasting (copy on the Mac is Command-C and paste in Ubuntu is Shift-Ctrl-v)

> Your Ubuntu guest system is now ready for downloading and installing software.

There are instructions for setting up virtual machines with the examples for each chapter. For this chapter, log back in and install the chapter examples:

> `git clone --recursive https:/ /github.com/essentialsofparallelcomputing/Chapter13.git`  
> `cd Chapter13 && sh -v README.virtualbox`

The commands in the README.virtualbox file install the software, and build and run the shallow water application. The real time graphics output should also work. You can also try the nvprof utility to profile the shallow water application as well.

***13.7 Cloud options: A flexible and portable capability***

When access to a specific GPU is limited (no supercomputer, laptop or desktop GPU, or remote server), you can make use of cloud computing.[1](#filepos1936374) Cloud computing refers to servers provided by large data centers. While most of these services are for more general users, some sites catering towards HPC-style services are beginning to appear. One of these sites is <http://mng.bz/Q2YG>. The Fluid Numerics Cloud cluster (fluid-slurm-gcp) setup on the Google Cloud Platform (GCP) has the Slurm batch scheduler and MPI. NVIDIA GPUs can be scheduled as well. Getting started can be a bit complicated. The Fluid Numerics site has some information to help with that process at [http://mng .bz/XYwv](http://mng.bz/XYwv).

The advantages of having hardware resources available on demand is often compelling. Google Cloud offers a \$300 trial credit that should be more than sufficient for exploring the service. There are other cloud providers and add-on services that can provide exactly what you need, or you can customize the environment yourself. Intel has set up a cloud service for testing out Intel GPUs so that developers have access to both software and hardware for their oneAPI initiative and their DPCPP compiler that provides a SYCL implementation. You can try it out by going to [https://software.intel .com/en-us/oneapi](https://software.intel.com/en-us/oneapi) and registering to use it.

***13.8 Further explorations***

Incorporating a workflow and development environment is especially important for GPU code development. With the great variety of possible hardware configurations, the examples presented in this chapter will likely require some customization for your situation. Indeed, the configuration and setup of development systems is one of the challenges of GPU computing. You may even find that it is easier to use one of the prebuilt Docker containers rather than figure out the process to configure and install software on your system.

We also suggest checking the most recent documentation relevant to your needs from the additional reading suggested in section 13.8.1. The tools and workflows are the fastest changing aspects of GPU programming. While the examples in this chapter will be generally relevant, the details are likely to change. Much of the software is so new that documentation on its use is still being developed.

***13.8.1 Additional reading***

The NVIDIA installation manual has some information on installing CUDA tools using a package manager at:

<https://docs.nvidia.com/cuda/cuda-installation-guide-linux/index.html#package-manager-installation>

NVIDIA has a couple of resources on their profiling tools and the transition from NVVP to the Nsight tool suite at the following sites:

- NVIDIA NSight Guide at <https://docs.nvidia.com/nsight-compute/NsightCompute/index.html#nvvp-guide>

- NVIDIA profiling tool comparison at <https://devblogs.nvidia.com/migrating-nvidia-nsight-tools-nvvp-nvprof/>

Other tools include the following:

- CodeXL has been released as open source under the GPUopen initiative. AMD has also removed its AMD brand from the tool to promote cross-platform development. For more information, see [https://github.com/GPUOpen-Tools/ CodeXL](https://github.com/GPUOpen-Tools/CodeXL).

- NVIDIA has a GPU Cloud with resources such as the PGI compilers in a container at <https://ngc.nvidia.com/catalog/containers/hpc:pgi-compilers>.

- AMD also has a webpage on setting up virtualization environments and containers. The virtualization instructions include a passthrough technique to get access to the GPU for computation. You find this information at [http://mng .bz/MgWW](http://mng.bz/MgWW)

***13.8.2 Exercises***

1.  Run nvprof on the stream triad example. You might try the CUDA version from chapter 12 or the OpenACC version from chapter 11. What workflow did you use for your hardware resources? If you don’t have access to an NVIDIA GPU, can you use another profiling tool?

2.  Generate a trace from nvprof and import it into NVVP. Where is the run time spent? What could you do to optimize it?

3.  Download a prebuilt Docker container from the appropriate vendor for your system. Start up the container and run one of the examples from chapter 11 or 12.

***Summary***

- Improving performance is a high priority for scientific and big data applications. Performance tools can help you get the most out of your GPU hardware.

- There are many profiling tools available for GPU programming. You should try out the many new and emerging capabilities that are available.

- Workflows are essential for efficient GPU code development. Explore what works for you in your environment and the available GPU hardware.

- There are workarounds through the use of containers, virtual machines, and cloud computing to handle incompatibilities, computing needs, and access to GPU hardware. These workarounds give access to a large sampling of GPU vendor hardware that might not otherwise be available.

------------------------------------------------------------------------

^(**1.**) See the README.cloud file in the examples for this chapter for the latest information on using the cloud.
