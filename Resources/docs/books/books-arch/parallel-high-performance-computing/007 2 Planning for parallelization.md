# 2 Planning for parallelization

***2 Planning for parallelization***

This chapter covers

- Planning steps for a parallel project
- Version control and team development workflows
- Understanding performance capabilities and limitations
- Developing a plan to parallelize a routine

Developing a parallel application or making an existing application run in parallel can feel challenging at first. Often, developers new to parallelism are unsure of where to begin and what pitfalls they might encounter. This chapter focuses on a workflow model for developing parallel applications as illustrated in figure 2.1. This model provides the context for where to get started and how to maintain progress in developing your parallel application. Generally, it is best to implement parallelism in small increments so that if problems are encountered, the last few commits can be reversed. This kind of pattern is suited to agile project management techniques.

**Figure 2.1 Our suggested parallel development workflow begins with preparing the application and then repeating four steps to incrementally parallelize an application. This workflow is particularly suited to an agile project management technique.**

Let’s imagine that you have been assigned a new project to speed up and parallelize an application from the spatial mesh presented in figure 1.9 (the Krakatau volcano example). This could be an image detection algorithm, a scientific simulation of the ash plume, or a model of the resulting tsunami waves, or all three of these. What steps can you take to have a successful parallelism project?

It is tempting to just jump into the project. But without thought and preparation, you greatly reduce your chance of success. As a start, you will need a project plan for this parallelism effort, so we begin here with a high-level overview of the steps in this workflow. Then we’ll dive deeper into each step as this chapter progresses, with a focus on the characteristics typical for a parallel project.

> **Rapid development: The parallel workflow**

> You first need to prepare your team and your application for rapid development. Because you have an existing serial application that works on the spatial mesh from figure 1.9, there will likely be lots of small changes with frequent tests to ensure that the results do not change. Code preparation includes setting up version control, developing a test suite, and ensuring code quality and portability. Team preparation will be centered around processes for the development procedures. As always, project management will address task management and scope control.

> To set the stage for the development cycle, you will need to determine the capabilities of the computing resources available, the demands of your application, and your performance requirements. System benchmarking helps to determine compute resource limitations, while profiling aids your understanding of the application's demands and its most expensive computational kernels. Computational kernels refer to sections of the application that are both computationally intensive and conceptually self-contained.

> From the kernel profiles, you will plan the tasks for parallelizing routines and implementing the changes. The implementation stage is only complete once the routine is parallelized and the code maintains portability and correctness. With these requirements satisfied, the changes will be committed to a version control system. After committing the incremental changes, the process begins again with an application and kernel profile.

***2.1 Approaching a new project: The preparation***

Figure 2.2 presents the recommended components in the preparation step. These are the items proven to be important specifically for parallelization projects.

**Figure 2.2 The recommended preparation components address issues that are important for parallel code development.**

At this stage, you will need to set up version control, develop a test suite for your application, and clean up existing code. Version control allows you to track the changes you make to your application over time. It permits you to quickly undo mistakes and track down bugs in your code at a later date. A test suite allows you to verify the correctness of your application with each change that is made to your code. When coupled with version control, this can be a powerful setup for rapidly developing your application.

With version control and code testing in place, you can now tackle the task of cleaning up your code. Good code is easy to modify and extend, and does not exhibit unpredictable behavior. Good, clean code can be ensured with modularity and checks for memory issues. Modularity means that you implement kernels as independent subroutines or functions with well-defined input and output. Memory issues can include memory leaks, out-of-bounds memory access, and use of uninitialized memory. Starting your parallelism work with predictable and quality code promotes rapid progress and predictable development cycles. It is hard to match your serial code if the original results are due to a programming error.

Finally, you will want to make sure your code is portable. This means that multiple compilers can compile your code. Having and maintaining compiler portability allows your application to target additional platforms, beyond the one you may currently have in mind. Further, experience shows that developing code to work with multiple compilers helps to find bugs before these are committed to your code’s version history. With the high performance computing landscape changing rapidly, portability allows you to adapt to changes much quicker down the line.

It is not unusual that the preparation time rivals that spent on the actual parallelism, especially for complex code. Including this preparation in your project scope and time estimates avoids frustrations with your project’s progress. In this chapter, we assume that you are starting from a serial or prototype application. However, you can still benefit from this workflow strategy even if you’ve already started parallelizing your code. Next, we discuss the four components of project preparation.

***2.1.1 Version control: Creating a safety vault for your parallel code***

It is inevitable with the many changes that occur during parallelism that you will suddenly find the code is broken or returning different results. Being able to recover from this situation by backing up to a working version is critically important.

> > > **NOTE** Check to see what kind of version control is in place for your application before beginning any parallelism work.

For your image detection project in our scenario, you find that there is already a version control system in place. But the ash plume model never had any version control. As you dig deeper, you find that there are actually four versions of the ash plume code in various developer’s directories. When there is a version control system in operation, you may want to review the processes your team uses for day-to-day operations. Perhaps the team thinks it is a good idea to switch to a “pull request” model, where changes are posted for review by other team members before being committed. Or you and your team may feel that the direct commit of the “push” model is more compatible with the rapid, small commits of parallelism tasks. In the push model, commits are made directly to the repository without review. In our example of the ash plume application without version control, the priority is to get something in place to tame the uncontrolled divergence of code among developers.

There are many options for version control. If you have no other preferences, we would suggest Git, the most common distributed version control system. A distributed version control system is one that allows multiple repository databases, rather than a single centralized system used in centralized version control. Distributed version control is advantageous for open source projects and where developers work on laptops, in remote locations, or other situations where they are not connected to a network or close to the central repository. In today’s development environment, this is a huge advantage. But it comes with the cost of additional complexity. Centralized version control is still popular and more appropriate for the corporate environment because there is only one place where all the information about the source code exists. Centralized control also provides better security and protection for proprietary software.

There are many good books, blogs, and other resources on how to use Git; we list a few at the end of the chapter. We also list some other common version control systems in chapter 17. These include free distributed version control systems such as Mercurial and Git, commercial systems such as PerForce and ClearCase, and for centralized version control, CVS and SVN. Regardless of which system you use, you and your team should commit frequently. The following scenario is especially common with parallelism tasks:

- I’ll commit after I add the next small change. . . .

- Just one more. . . . Then all of a sudden the code is not working.

- It’s too late to commit now!

This happens to me far too often. So I try to avoid the problem by committing regularly.

> > > **TIP** If you do not want lots of small commits in the main repository, you can collapse the commits with some version control systems such as Git, or you can maintain a temporary version control system just for yourself.

The commit message is where the commit author can communicate what task is being addressed and why certain changes were made, whether for self or for current or future team members. Every team has their own preference for how detailed these messages should be; we recommend using as much detail as possible in your commit messages. This is your opportunity to save yourself from later confusion by being diligent today.

In general, commit messages include a summary and a body. The summary provides a short statement indicating clearly what new changes the commit covers. Additionally, if you use an issue tracking system, the summary line will reference an issue number from that system. Finally, the body contains most of the “why” and “how” behind the commit.

> **Examples of commit messages**

- Bad commit message:

- `Fixed a bug`

- Good commit message:

- `Fixed the race condition in the OpenMP version of the blur operator`

- Great commit message:

- `[Issue #21] Fixed the race condition in the OpenMP version of the blur operator.`  
  > `* The race condition was causing non-reproducible results amongst GCC, Intel, and PGI compilers. To fix this, an OMP BARRIER was introduced to force threads to synchronize just before calculating the weighted stencil sum.`  
  > `* Confirmed that the code builds and runs with GCC, Intel, and PGI compilers and produces consistent results.`

> The first message doesn’t really help anyone understand what bug was fixed. The second message helps pinpoint the resolution to problems that involve race conditions in the blur operator. The last message references an issue number (#21) in an outside issue tracking system and provides the commit summary on the first line. The commit body, the two bullet points beneath the summary, provides more details about what specifically was needed and why, and indicates to other developers that you took the time to test your version before committing it.

With a plan for version control and at least a rough agreement on your team’s development processes, we are ready to move on to the next step.

***2.1.2 Test suites: The first step to creating a robust, reliable application***

A test suite is a set of problems that exercise parts of an application to guarantee that related parts of the code still work. Test suites are a necessity for all but the simplest of codes. With each change, you should test to see that the results that you get are the same. This sounds simple, but some code can reach slightly different results with different compilers and numbers of processors.

> **Example: Krakatau scenario test for validated results**

> Your project has an ocean wave simulation application that generates validated results. Validated results are simulation results that are compared to experimental or real-world data. Simulation code that has been validated is valuable. You don’t want to lose that while you parallelize the code.

> In our scenario, you and your team used two different compilers for development and production. The first is the C compiler in the GNU Compiler Collection (GCC), the ubiquitous, freely-available compiler dispersed with all Linux distributions and many other operating systems. The C compiler is colloquially referred to as the GCC compiler. Your application also uses the commercially available Intel C compiler.

> The following figure shows the hypothetical results for the validated test problem that predicts wave height and total mass. The output varies slightly depending on which compiler and the number of processors used in the simulation.

>   

> **Which differences between calculations with various compilers and numbers of processors are acceptable?**

> In this example, there are variations in the two metrics reported from the program. Without additional information, it is difficult to determine which is correct and which variations in the solution are acceptable. In general, differences in your program output can be due to

- Changes in the compiler or the compiler version

- Changes in hardware

- Compiler optimizations or small differences between compilers or compiler versions

- Changes in the order of operations, especially due to code parallelism

In the following sections, we’ll discuss why such differences can arise, how to determine which variations are reasonable, and how to design tests that catch real bugs before these are committed to your repository.

***UNDERSTANDING CHANGES IN RESULTS DUE TO PARALLELISM***

The parallelism process inherently changes the order of operations, which slightly modifies the numerical results. But errors in parallelism also generate small differences. This is crucial to understand in parallel code development because we need to compare to a single processor run to determine if our parallelism coding is correct. We’ll discuss a way to reduce the numerical errors so that the parallelism errors are more obvious in section 5.7, when we discuss techniques for global sums.

For our test suite, we will need a tool that compares numerical fields with a small tolerance for differences. In the past, test suite developers would have to create a tool for this purpose, but a few numerical diff utilities have appeared on the market in recent years. Two such tools are

- Numdiff from <https://www.nongnu.org/numdiff/>

- ndiff from <https://www.math.utah.edu/~beebe/software/ndiff/>

Alternatively, if your code outputs its state in HDF5 or NetCDF files, these formats come with utilities that allow you to compare values stored in the files with varying tolerances.

- HDF5® is version 5 of the software originally known as Hierarchical Data Format, now called HDF. It is freely available from The HDF Group ([https://www .hdfgroup.org/](https://www.hdfgroup.org/)) and is a common format used to output large data files.

- NetCDF or the Network Common Data Form is an alternate format used by the climate and geosciences community. Current versions of NetCDF are built on top of HDF5. You can find these libraries and data formats at the Unidata Program Center’s website (<https://www.unidata.ucar.edu/software/netcdf/>).

Both of these file formats use binary data for speed and efficiency. Binary data is the machine representation of the data. This format just looks like gibberish to you and me, but HDF5 has some useful utilities that allow us to look at what’s inside. The h5ls utility lists the objects in the file, such as the names of all the data arrays. The h5dump utility dumps the data in each object or array. And most importantly for our purposes here, the h5diff utility compares two HDF files and reports the difference above a numeric tolerance. HDF5 and NetCDF along with other parallel input/output (I/O) topics will be discussed in more detail in chapter 16.

***USING CMAKE AND CTEST TO AUTOMATICALLY TEST YOUR CODE***

Many testing systems have become available in recent years. This includes CTest, Google test, pFUnit test, and others. You can find more information on tools in chapter 17. For now, let’s look at a system created using CTest and ndiff.

CTest is a component of the CMake system. CMake is a configuration system that adapts generated makefiles to different systems and compilers. Incorporating the CTest testing system into CMake couples the two tightly together into a unified system. This provides a lot of convenience to the developer. The process of implementing tests using CTest is relatively easy. The individual tests are written as any sequence of commands. To incorporate these into the CMake system requires adding the following to the CMakeLists.txt:

- `enable_testing()`

- `add_test(<testname> <executable name> <arguments to executable>)`

Then you can invoke the tests with `make test`, `ctest`, or you can select individual tests with `ctest -R mpi`, where `mpi` is a regular expression that runs any matching test names. Let’s just walk through an example of creating a test using the CTest system.

> **Example: CTest prerequisites**

> You will need MPI, CMake, and ndiff installed to run this example. For MPI (Message Passing Interface), we’ll use OpenMPI 4.0.0 and CMake 3.13.3 (includes CTest) on the Mac with older versions on Ubuntu. We’ll use the GCC compiler, version 8, installed on a Mac rather than the default compiler. Then OpenMPI, CMake, and GCC (GNU Compiler Collection) are installed with a package manager. We’ll use Homebrew on the Mac and Apt, and Synaptic on Ubuntu Linux. Be sure to get the development headers from libopenmpi-dev if these are split out from the run time. ndiff is installed manually by downloading the tool from [https://www.math.utah.edu/~beebe/ software/ndiff/](https://www.math.utah.edu/~beebe/software/ndiff/) and running `./configure`, `make`, and `make install`.

Make two source files as shown in listing 2.1 to create applications for this simple testing system. We’ll use a timer to produce small differences in output from both a serial and a parallel program. Note that you’ll find the source code for this chapter at <https://github.com/EssentialsofParallelComputing/Chapter2>.

**Listing 2.1 Simple timing programs for demonstrating the testing system**

> `C Program, TimeIt.c`  
> `1 #include <unistd.h>`  
> `2 #include <stdio.h>`  
> `3 #include <time.h>`  
> `4 int main(int argc, char *argv[]){`  
> `5    struct timespec tstart, tstop, tresult;`  
> `6    clock_gettime(CLOCK_MONOTONIC, &tstart);    `❶  
> `7    sleep(10);                                  `❶  
> `8    clock_gettime(CLOCK_MONOTONIC, &tstop);     `❶  
> `9    tresult.tv_sec =`  
> `         tstop.tv_sec - tstart.tv_sec;            `❷  
> `10    tresult.tv_usec =`  
> `         tstop.tv_nsec - tstart.tv_nsec;          `❷  
> `11    printf("Elapsed time is %f secs\n",`  
> `         (double)tresult.tv_sec +                 `❸  
> `12       (double)tresult.tv_nsec*1.0e-9);         `❸  
> `13 }`  
> `MPI Program, MPITimeIt.c`  
> `1 #include <unistd.h>`  
> `2 #include <stdio.h>`  
> `3 #include <mpi.h>`  
> `4 int main(int argc, char *argv[]){`  
> `5    int mype;`  
> `6    MPI_Init(&argc, &argv);                     `❹  
> `7    MPI_Comm_rank(MPI_COMM_WORLD, &mype);       `❹  
> `8    double t1, t2;`  
> `9    t1 = MPI_Wtime();                           `❺  
> `10    sleep(10);                                  `❺  
> `11    t2 = MPI_Wtime();                           `❺  
> `12    if (mype == 0)`  
> `         printf( "Elapsed time is %f secs\n",     `❻  
> `                   t2 - t1);                      `❻  
> `13    MPI_Finalize();                             `❼  
> `14 }`

❶ Starts timer, calls sleep, then stops the timer

❷ Timer has two values for resolution and to prevent overflows.

❸ Prints calculated time

❹ Initializes MPI and gets processor rank

❺ Starts timer, calls sleep, then stops the timer

❻ Prints timing output from first processor

❼ Shuts down MPI

Now you need a test script that runs the applications and produces a few different output files. After these run, there should be numerical comparisons of the output. Here is an example of the process you can put in a file called mympiapp.ctest. You should do a `chmod +x` to make it executable.

> `mympiapp.ctest`  
> `1 #!/bin/sh`  
> `2 ./TimeIt > run0.out                                `❶  
> `3 mpirun -n 1 ./MPITimeIt > run1.out                 `❷  
> `4 mpirun -n 2 ./MPITimeIt > run2.out                 `❸  
>   
> `5 ndiff --relative-error 1.0e-4 run1.out run2.out    `❹  
> `6 test1=$?                                           `❺  
>   
> `7 ndiff --relative-error 1.0e-4 run0.out run2.out    `❻  
> `8 test2=$?                                           `❻  
>   
> `9 exit "$(($test1+$test2))"                          `❼

❶ Runs a serial test

❷ Runs the first MPI test on 1 processor

❸ Runs the second MPI test on 2 processors

❹ Compares the output for the two MPI jobs to get the test to fail

❺ Captures the status set by the ndiff command

❻ Compares the serial output to the 2 processor run

❼ Exits with the cumulative status code so CTest can report pass or fail

This test first compares the output for a parallel job with 1 and 2 processors with a tolerance of 0.1% on line 5. Then it compares the serial run to the 2 processor parallel job on line 7. To get the tests to fail, try reducing the tolerance to 1.0e-5. CTest uses the exit code on line 9 to report pass or fail. The simplest way to add a bunch of CTest files to the test suite is to use a loop that finds all the files ending in .ctest and adds these to the CTest list. Here is an example of a CMakeLists.txt file with the additional instructions to create the two applications:

> `CMakeLists.txt`  
> `1 cmake_minimum_required (VERSION 3.0)`  
> `2 project (TimeIt)`  
> `3`  
> `4 enable_testing()                                   `❶  
> `5`  
> `6 find_package(MPI)                                  `❷  
> `7`  
> `8 add_executable(TimeIt TimeIt.c)                    `❸  
> `9`  
> `10 add_executable(MPITimeIt MPITimeIt.c)              `❸  
> `11 target_include_directories(MPITimeIt PUBLIC.       `❹  
> `      ${MPI_INCLUDE_PATH})                            `❹  
> `12 target_link_libraries(MPITimeIt ${MPI_LIBRARIES})  `❹  
> `13`  
> `14 file(GLOB TESTFILES RELATIVE`  
> `     "${CMAKE_CURRENT_SOURCE_DIR}" "*.ctest")         `❺  
> `15 foreach(TESTFILE ${TESTFILES})                     `❺  
> `16    add_test(NAME ${TESTFILE} WORKING_DIRECTORY`  
> `         ${CMAKE_BINARY_DIR}                          `❺  
> `17    COMMAND sh`  
> `         ${CMAKE_CURRENT_SOURCE_DIR}/${TESTFILE})     `❺  
> `18 endforeach()                                       `❺  
> `19`  
> `20 add_custom_target(distclean`  
> `      COMMAND rm -rf CMakeCache.txt CMakeFiles        `❻  
> `21    CTestTestfile.cmake Makefile Testing`  
> `         cmake_install.cmake)                         `❻

❶ Enables CTest functionality in CMake

❷ CMake built-in routine to find most MPI packages

❸ Adds TimeIt and MPITimeIt build targets with their source code files

❹ Needs an include path to the mpi.h file and to the MPI library

❺ Gets all files with the extension .ctest and adds those to the test list for CTest

❻ A custom command, distclean, removes created files.

The `find_package(MPI)` command on line 6 defines MPI_FOUND, MPI_INCLUDE\_ PATH, and MPI_LIBRARIES. These variables include the language in newer CMake versions of MPI\_\<lang\>\_INCLUDE_PATH, and MPI\_\<lang\>\_LIBRARIES so that there are different paths for C, C++, and Fortran. Now all that remains is to run the test with

> `mkdir build && cd build`  
> `cmake ..`  
> `make`  
> `make test`

or

> `ctest`

You can also get the output for failed tests with

> `ctest --output-on-failure`

You should get some results like the following:

> `Running tests...`  
> `Test project /Users/brobey/Programs/RunDiff`  
> `    Start 1: mpitest.ctest`  
> `1/1 Test #1: mpitest.ctest ....................   Passed   30.24 sec`  
>   
> `100% tests passed, 0 tests failed out of 1`  
>   
> `Total Test time (real) =  30.24 sec`

This test is based on the sleep function and timers, so it may or may not pass. Test results are in Testing/Temporary/\*.

In this test, we compared the output between individual runs of the application. It is also good practice to store a gold standard file from one of the runs along with the test script to compare against as well. This comparison detects changes that will cause a new version of the application to get different results than earlier versions. When this happens, it is a red flag; check if the new version is still correct. If so, you should update the gold standard.

Your test suite should exercise as many parts of the code as is practical. The metric code coverage quantifies how well the test suite does its task, which is expressed as a percentage of the lines of source code. There is an old saying from test developers that the part of the code that doesn’t have a test is broken because even if it isn’t now, it will be eventually. With all of the changes made when parallelizing code, breakage is inevitable. While high code coverage is important, for our parallelism efforts, it is more critical that there are tests for the parts of the code you are parallelizing. Many compilers have the capability to generate code coverage statistics. For GCC, gcov is the profiling tool, and for Intel, it is Codecov. We’ll take a look at how this works for GCC.

> **Code coverage with GCC**

1.  Add the flags `-fprofile-arcs` and `-ftest-coverage` when compiling and linking

2.  Run the instrumented executable on a series of tests

3.  Run `gcov <source.c>` to get the coverage for each file

    > **NOTE** For builds with CMake, add an extra .c extension to the source filename; for example, gcov CMakeFiles/stream_triad.dir/stream_triad.c.c handles the extension added by CMake.

4.  You will get output something like this:

> `88.89% of 9 source lines executed in file <source>.c`  
> `Creating <source>.c.gcov`

> The gcov output file contains a listing with each line prepended with the number of times it was executed.

***UNDERSTANDING THE DIFFERENT KINDS OF CODE TESTS***

There are also different kinds of testing systems. In this section, we’ll cover the following types:

- Regression tests—Run at regular intervals to keep the code from backsliding. This is typically done nightly or weekly using the cron job scheduler that launches jobs at specified times.

- Unit tests—Tests the operation of subroutines or other small parts of code during development.

- Continuous integration tests—Gaining in popularity, these tests are automatically triggered to run by a commit to the code.

- Commit tests—A small set of tests that can be run from the command line in a fairly short time and are used before commits.

All of these testing types are important for a project and, rather than just relying on one, these should be used together as figure 2.3 illustrates. Testing is particularly important for parallel applications because detecting bugs earlier in the development cycle means that you are not debugging 1,000 processors 6 hours into a run.

**Figure 2.3 The different test types address different parts of code development to create a high quality code that is always ready to release.**

Unit tests are best created as you develop the code. True aficionados of unit tests use test-driven development (TDD), where the tests are created first and then the code is written to pass these. Incorporating these type of tests into parallel code development includes testing their operation in the parallel language and implementation. Identifying problems at this level is far easier to resolve.

Commit tests are the first tests that you should add to a project to be heavily used in the code modification phase. These tests should exercise all of the routines in the code. By having these tests readily available, team members can run these before making a commit to the repository. We recommend that developers invoke these tests from the command line like a Bash or Python script, or a makefile, prior to a commit.

> **Example: A development workflow with commit tests using CMake and CTest**

> To make a commit test within CMakeLists.txt, create the three files shown in the following listing. Use the Timeit.c from the previous test, but change the sleep interval from 10 to 30.

> **Creating a commit test with CTest**

> `blur_short.ctest`  
> `1 #!/bin/sh`  
> `2 make`  
>   
> `blur_long.ctest`  
> `1 #!/bin/sh`  
> `2 ./TimeIt`  
>   
> `CMakeLists.txt`  
> `1 cmake_minimum_required (VERSION 3.0)`  
> `2 project (TimeIt)`  
> `3`  
> `4 enable_testing()                                  `❶  
> `5`  
> `6 add_executable(TimeIt TimeIt.c)`  
> `7`  
> `8 add_test(NAME blur_short_commit WORKING_DIRECTORY`  
> `         ${CMAKE_BINARY_DIRECTORY}                   `❷  
> `9    COMMAND`  
> `   ${CMAKE_CURRENT_SOURCE_DIR}/blur_short.ctest)     `❷  
> `10 add_test(NAME blur_long WORKING_DIRECTORY`  
> `         ${CMAKE_BINARY_DIRECTORY}                   `❷  
> `11    COMMAND`  
> `   ${CMAKE_CURRENT_SOURCE_DIR}/blur_long.ctest)      `❷  
> `12`  
> `13 add_custom_target(commit_tests`  
> `      COMMAND ctest -R commit DEPENDS <myapp>)       `❸  
> `14`  
> `15 add_custom_target(distclean`  
> `      COMMAND rm -rf CMakeCache.txt CMakeFiles       `❹  
> `16      CTestTestfile.cmake Makefile Testing`  
> `        cmake_install.cmake)                         `❹

> ❶ Enables CTest functionality in CMake

> ❷ Adds two tests, one with commit in the name

> ❸ Custom target commit_tests runs all tests with “commit” in the name.

> ❹ A custom command, distclean, removes the created files.

 

The commit tests can be run with `ctest -R commit` or with the custom target added to the CMakeLists.txt with `make commit_tests`. A `make test` or `ctest` command runs all the tests including the long test, which takes a while. The commit test command picks out the tests with commit in the name to get a set of tests that covers critical functionality but runs a little faster. Now the workflow is

1.  Edit the source code: `vi mysource.c`

2.  Build code: `make`

3.  Run the commit tests: `make commit_tests`

4.  Commit the code changes: `git commit`

And repeat. Continuous integration tests are invoked by a commit to the main code repository. This is an additional guard against committing bad code. The tests can be the same as the commit tests or can be more extensive. Top continuous integration tools for these types of tests are

- Jenkins (<https://www.jenkins.io>)

- Travis CI for GitHub and Bitbucket (<https://travis-ci.com>)

- GitLab CI (<https://about.gitlab.com/stages-devops-lifecycle/continuous-integration/>)

- CircleCI (<https://circleci.com>)

Regression tests are usually set up to run overnight through a cron job. This means that the test suites can be more extensive than the test suites for other testing types. These tests can be longer but should complete by the morning report. Additional tests, such as memory checks and code coverage are often run as regression tests due to the longer run times and the periodicity of the reports. The results of regression tests are often tracked over time and a “wall of passes” is considered as an indication of the project’s well-being.

***FURTHER REQUIREMENTS OF AN IDEAL TESTING SYSTEM***

While the testing system as described previously is sufficient for most purposes, there is more that can be helpful for larger HPC projects. These types of HPC projects can have extensive test suites and might also need to be run in a batch system to access larger resources.

The Collaborative Testing System (CTS) at [https://sourceforge.net/projects/ ctsproject/](https://sourceforge.net/projects/ctsproject/) provides an example of a system that was developed for these demands. It uses a Perl script to run a fixed set of test servers, typically 10, launching the tests in parallel to a batch system. As each test completes, it launches the next. This avoids flooding the system with jobs all at once. The CTS system also autodetects the batch system and type of MPI and adjusts the scripts for each system. The reporting system uses cron jobs with the tests launched early in the overnight period. The cross-platform report launches in the morning and then is sent out.

> **Example: Krakatau scenario test suite for HPC projects**

> After reviewing your applications, you find there is a large user base for the image detection application. So your team decides to set extensive regression tests before every commit to avoid impacting the users. Longer running memory correctness tests run overnight, and the performance tracked weekly. The ocean wave simulation is new, however, and has fewer users, but you want to ensure the validated problemcontinues to give the same answer. It is too long to run for a commit test, so you run a shortened version and the full version weekly.

> For both applications, a continuous integration test is set up to build the code and run a few smaller tests. The ash plume model just started being developed, so you decide to use unit tests to check each new section of code as it is added.

***2.1.3 Finding and fixing memory issues***

Good code quality is paramount. Parallelizing often causes any code flaw to appear; this might be uninitialized memory or memory overwrites.

- Uninitialized memory is memory that is accessed before its values are set. When you allocate memory to your program, it gets whatever values are in those memory locations. This leads to unpredictable behavior if it is used before being set.

- Memory overwrites occur when data is written to a memory location that isn’t owned by a variable. An example of this is writing past the bounds of an array or string.

To catch these sorts of problems, we suggest using memory correctness tools to thoroughly check your code. One of the best of these is the freely-available Valgrind program. Valgrind is an instrumentation framework that operates at the machine-code level by executing instructions through a synthetic CPU. There are many tools that have been developed under the Valgrind umbrella. The first step is to install Valgrind on your system using a package manager. If you are running the latest version of macOS, you may find that it takes a few months for Valgrind to be ported to the new kernel. Your best bet for this is to run Valgrind on a different computer, an older macOS or spin up a virtual machine or Docker image.

To run Valgrind, execute your program as usual, inserting the `valgrind` command at the front. For MPI jobs, the `valgrind` command gets placed after `mpirun` and before your executable name. Valgrind works best with the GCC compiler because that development team adopted it, working to eliminate false positives that can clutter the diagnostic output. It is suggested that when using Intel compilers, compile without vectorization to avoid warnings about the vector instructions. You can also try the other memory correctness tools that are listed in section 17.5.

***USING VALGRIND MEMCHECK TO FIND MEMORY ISSUES***

The Memcheck tool is the default tool in the Valgrind tool suite. It intercepts every instruction and checks it for various types of memory errors, generating diagnostics at the start, during, and at the end of the run. This slows down the run by an order of magnitude. If you have not used it before, be prepared for a lot of output. One memory error leads to many others. The best strategy is to start with the first error, fix it, and run again. To see how Valgrind works, try the example code in listing 2.2. To execute Valgrind, insert the `valgrind` command before the executable name either as

> `valgrind <./my_app>`

or

> `mpirun -n 2 valgrind <./myapp>`

**Listing 2.2 Example code for Valgrind memory errors**

> ` 1 #include <stdlib.h>`  
> `2`  
> `3 int main(int argc, char *argv[]){`  
> `4    int ipos, ival;                                    `❶  
> `5    int *iarray = (int *) malloc(10*sizeof(int));`  
> `6    if (argc == 2) ival = atoi(argv[1]);`  
> `7    for (int i = 0; i<=10; i++){ iarray[i] = ipos; }   `❷  
> `8    for (int i = 0; i<=10; i++){`  
> `9       if (ival == iarray[i]) ipos = i;                `❸  
> `10    } `  
> `11 }`

❶ ipos is not given a value.

❷ Loads uninitialized memory from ipos into iarray

❸ Flags uninitialized memory

Compile this code with `gcc -g -o test test.c` and then run it with `valgrind—leak-check=full ./test 2`. The output from Valgrind is interspersed within the program’s output and can be identified by the prefix with double equal signs (==). The following shows some of the more important parts of the output from this example:

> `==14324== Invalid write of size 4`  
> `==14324==    at 0x400590: main (test.c:7)`  
> `==14324==`  
> `==14324== Conditional jump or move depends on uninitialized value(s)`  
> `==14324==    at 0x4005BE: main (test.c:9)`  
> `==14324==`  
> `==14324== Invalid read of size 4`  
> `==14324==    at 0x4005B9: main (test.c:9)`  
> `==14324==`  
> `==14324== 40 bytes in 1 blocks are definitely lost in loss record 1 of 1`  
> `==14324==    at 0x4C29C23: malloc (vg_replace_malloc.c:299)`  
> `==14324==    by 0x40054F: main (test.c:5)`

This output displays reports on several memory errors. The trickiest one to understand is the uninitialized memory report. Valgrind reports the error on line 9 when a decision was made with the uninitialized value. The error is actually on line 7 where `iarray` is set to `ipos`, which was not given a value. It can take some careful analysis in a more complex program to determine the source of the error.

***2.1.4 Improving code portability***

A last code preparation requirement improves code portability to a wider range of compilers and operating systems. Portability begins with the base HPC language, generally C, C++, or Fortran. Each of these languages maintains standards for compiler implementations, and new standard releases occur periodically. But this does not mean that compilers implement these readily. Often the lag time from release to full implementation by compiler vendors can be long. For example, the Polyhedron Solutions website (<http://mng.bz/yYne>) reports that no Linux Fortran compiler fully implements the 2008 standard, and less than half fully implement the 2003 standard. Of course, what matters is if the compilers have implemented the features that you want. C and C++ compilers are usually more up-to-date in their implementations of new standards, but the lag time can still cause problems for aggressive development teams. Also, even if the features are implemented, it does not mean these work in a wide variety of settings.

Compiling with a variety of compilers helps to detect coding errors or identify where code is pushing the “edge” on language interpretations. Portability provides flexibility when using tools that work best in a particular environment. For example, Valgrind works best with GCC, but Intel® Inspector, a thread correctness tool, works best when you compile the application with Intel compilers. Portability also helps when using parallel languages. For example, CUDA Fortran is only available with the PGI compiler. The current set of implementations of GPU directive-based languages OpenACC and OpenMP (with the `target` directive) are only available on a small set of compilers. Fortunately, MPI and the OpenMP for CPUs are widely available for many compilers and systems. At this point, we need to it make clear that there are three distinct OpenMP capabilities: 1) vectorization through SIMD directives, 2) CPU threading from the original OpenMP model, and 3) offloading to an accelerator, generally a GPU, through the new `target` directives.

> **Example: Krakatau scenario and code portability**

> Your image detection application only compiles with the GCC compiler. Your parallelism project adds OpenMP threading. Your team decides to get it to compile with the Intel compiler so that you can use the Intel Inspector to find thread race conditions. The ash plume simulation is written in Fortran and targeted to run on GPUs. Based on your research of current GPU languages, you decide to include PGI as one of your development compilers so you can use CUDA Fortran.

***2.2 Profiling: Probing the gap between system capabilities and application performance***

Profiling (figure 2.4) determines the hardware performance capabilities and compares that with your application performance. The difference between the capabilities and current performance yields the potential for performance improvement.

**Figure 2.4 The purpose of the profiling step is to identify the most important parts of the application code that need to be addressed.**

The first part of the profiling process is to determine what is the limiting aspect of your application’s performance. We’ll detail possible performance limitations for applications in section 3.1. Briefly, most applications today are limited by memory bandwidth or a limitation that closely tracks memory bandwidth. A few applications might be limited by available floating-point operations (flops). We’ll present ways to calculate theoretical performance limits in section 3.2. We’ll also describe benchmark programs that can measure the achievable performance for that hardware limitation.

Once the potential performance is understood, then you can profile your application. We’ll present the process of using some profiling tools in section 3.3. The gap between the current performance of your application and the hardware capabilities for the limiting aspect of your application then become the target for improvement for the next steps in parallelism.

***2.3 Planning: A foundation for success***

Armed with the information gathered on your application and the targeted platforms, it is time to put some details into a plan. Figure 2.5 shows parts of this step. With the effort that’s required in parallelism, it is sensible to research prior work before starting the implementation step.

**Figure 2.5 The planning steps lay the foundation for a successful project.**

It is likely that similar problems were encountered in the past. You’ll find many research articles on parallelism projects and techniques published in recent years. But one of the richest sources of information includes the benchmarks and mini-apps that have been released. With mini-apps, you have not only the research but also the actual code to study.

***2.3.1 Exploring with benchmarks and mini-apps***

The high performance computing community has developed many benchmarks, kernels, and sample applications for use in benchmarking systems, performance experiments, and algorithm development. We’ll list some of these in section 17.4. You can use benchmarks to help select the most appropriate hardware for your application, and mini-apps provide help on the best algorithms and coding techniques.

Benchmarks are intended to highlight a specific characteristic of hardware performance. Now that you have a sense of what is the performance limit of your application, you should look at the benchmarks most applicable to your situation. If you compute on large arrays that are accessed in a linear fashion, then the stream benchmark is appropriate. If you have an iterative matrix solver as your kernel, then the High Performance Conjugate Gradient (HPCG) benchmark might be better. Mini-apps are more focused on a typical operation or pattern found in a class of scientific applications.

It is worthwhile to see if any of these benchmarks or mini-apps are similar to the parallel application you are developing. If so, studying how these do similar operations can save a lot of effort. Often, a lot of work has been done with the code to explore how to get the best performance, to port to other parallel languages and platforms, or to quantify performance characteristics.

Currently benchmarks and mini-apps are predominantly from the field of scientific computing. We’ll use some of these in our examples, and you are encouraged to use these for your experimentation and as example code. Many of the key operations and parallel implementations are demonstrated in these examples.

> **Example: Ghost cell updates**

> Many mesh-based applications distribute their mesh across processors in a distributed memory implementation (see figure 1.13). Because of this, these applications need to update the boundaries of their mesh with values from an adjacent processor.

> This operation is called a ghost cell update. Richard Barrett at Sandia National Laboratories developed the MiniGhost mini-app to experiment with different ways to perform this type of operation. The MiniGhost mini-app is part of the Mantevo suite of mini-apps available at <https://mantevo.org/default.php>.

***2.3.2 Design of the core data structures and code modularity***

The design of data structures has a long ranging impact on your application. This is one of the decisions that needs to be made up front, realizing that changing the design later becomes difficult. In chapter 4, we go through some of the considerations that are important, along with a case study that demonstrates the analysis of the performance of different data structures.

To begin, focus on the data and data movement. This is the dominant consideration with today’s hardware platforms. It also leads into an effective parallel implementation where the careful movement of data becomes even more important. If we consider the filesystem and network as well, data movement dominates everything.

***2.3.3 Algorithms: Redesign for parallel***

At this point, you should evaluate the algorithms in your application. Can these be modified for parallel coding? Are there algorithms that have better scalability? For example, your application may have a section of code that only takes 5% of the run time but has an N ² algorithmic scaling, while the rest of the code scales with N, where N is the number of cells or some other data component. As the problem size grows, the 5% soon becomes 20% and then even higher. Soon it is dominating the run time. To identify these kinds of issues, you might want to profile a larger problem and then look at the growth in the run time rather than the absolute percentage.

> **Example: Data structure for the ash plume model**

> Your ash plume model is in the early stages of development. There are several proposed data structures and breakdowns of the functional steps. Your team decides to spend a week analyzing the alternatives before they become fixed in the code, knowing that it will be difficult to change in the future. One of the decisions is which multi-material data structure to use and, because many materials will only be in small regions of the mesh, whether there is a good way to take advantage of this. You decide to explore a sparse data storage data structure to save memory (some are discussed in section 4.3.2) and for a faster code.

> **Example: Algorithm selection for the wave simulation code**

> The parallelism work on the wave simulation code is projected to add OpenMP and vectorization. You have heard of different implementation styles for each of these parallelism approaches. You assign two team members to review recent papers for insights on the approaches that work best. One of your team members expresses concerns about the parallelism of one of the more difficult routines, which has a complicated algorithm. The current technique does not look straightforward to parallelize. You agree and ask the team member to look into alternative algorithms that might be different than what is currently being done.

***2.4 Implementation: Where it all happens***

This is the step I think of as hand-to-hand combat. Down in the trenches, line-by-line, loop-by-loop, and routine-by-routine the code is transformed to parallel code. This is where all your knowledge of parallel implementations on CPUs and GPUs comes to effect. As figure 2.6 shows, this material will be covered in much of the rest of the book. The chapters on parallel programming languages, chapters 6-8 for CPUs and chapters 9-13 for GPUs, begin your journey to developing this expertise.

**Figure 2.6 The implementation step utilizes parallel languages and skills developed in the rest of the book.**

During the implementation step, it is important to keep track of your overall goals. You may or may not have decided on your parallel language at this point. Even if you have, you should be willing to reassess your choice as you get deeper into the implementation. Some of the initial considerations for your choice of direction for the project include

- Are your speedup requirements fairly modest? You should explore vectorization and shared memory (OpenMP) parallelism in chapters 6 and 7.

- Do you need more memory to scale up? If so, you will want to explore distributed memory parallelism in chapter 8.

- Do you need large speedups? Then GPU programming is worth looking into in chapters 9-13.

The key in this implementation step is to break down the work into manageable chunks and divide out the work among your team members. There is both the exhilaration of getting an order of magnitude speedup in a routine and realizing that the overall impact is small, and there is still a lot of work to do. Perseverance and teamwork are important in reaching the goal.

> **Example: Reassessment of parallel language**

> Your project to add OpenMP and vectorization to the wave simulation code is going well. You have gotten an order of magnitude speedup for typical calculations. But as the application speeds up, your users want to run larger problems and they don’t have enough memory. Your team begins to think about adding MPI parallelism to access additional nodes where more memory is available.

***2.5 Commit: Wrapping it up with quality***

The commit step finalizes this part of the work with careful checks to verify that code quality and portability are maintained. Figure 2.7 shows the components of this step. How extensive these checks are is highly dependent on the nature of the application. For production applications with many users, the tests need to be far more thorough.

> > > **NOTE** At this point, it is easier to catch relatively small-scale problems than it is to debug complications six days into a run on a thousand processors.

**Figure 2.7 The goal of the commit step is to create a solid rung on the ladder to reaching your end goal.**

The team must buy-in to the commit process and work together to follow it. It is suggested that there be a team meeting to develop the procedures for all to follow. The processes used during the initial efforts to improve code quality and portability can be exploited in creating your procedures. Lastly, the commit process should be re-evaluated periodically and adapted for the current project needs.

> **Example: Re-evaluating your team’s code development process**

> Your wave simulation application team has gotten the first increment of work for adding OpenMP to the application. But now the application is occasionally crashing with no explanation. One of your team members realizes that it might be due to thread race conditions. Your team implements an additional step to check for these conditions as part of the commit process.

***2.6 Further explorations***

In this chapter, we have only brushed the surface of how to approach a new project and what the available tools can do. For more information, explore the resources and try some of the exercises in the following sections.

***2.6.1 Additional reading***

Additional expertise with today’s distributed version control tools benefits your project. At least one member of your team should research the many resources on the web that discuss how to use your chosen version control system. If you use Git, the following books from Manning are good resources:

- Mike McQuaid, Git in Practice (Manning, 2014).

- Rick Umali, Learn Git in a Month of Lunches (Manning, 2015).

Testing is vitally important in the parallel development workflow. Unit testing is perhaps the most valuable but also the most difficult to implement well. Manning has a book that gives a much more thorough discussion of unit testing:

Vladimir Khorikov, Unit Testing Principles, Practices, and Patterns (Manning, 2020).

Floating-point arithmetic and precision is an underappreciated topic, despite its importance to every computational scientist. The following is a good read and overview on floating-point arithmetic:

David Goldberg, “What every computer scientist should know about floating-point arithmetic,” ACM Computing Surveys (CSUR) 23, no. 1 (1991): 5-48.

***2.6.2 Exercises***

1.  You have a wave height simulation application that you developed during graduate school. It is a serial application and because it was only planned to be the basis for your dissertation, you didn’t incorporate any software engineering techniques. Now you plan to use it as the starting point for an available tool that many researchers can use. You have three other developers on your team. What would you include in your project plan for this?

2.  Create a test using CTest

3.  Fix the memory errors in listing 2.2

4.  Run Valgrind on a small application of your choice

This chapter has covered a lot of ground with many of the details necessary for a parallel project plan. The estimation of performance capabilities and uses of tools to extract information on hardware characteristics and application performance give solid, concrete data points to populate the plan. The proper use of these tools and skills can help build a solid foundation for a successful parallel project.

***Summary***

- Code preparation is a significant part of parallelism work. Every developer is surprised at the amount of effort spent preparing the code for the project. But this time is well spent in that it is the foundation for a successful parallelism project.

- You should improve your code quality for parallel code. Code quality must be an order of magnitude better than typical serial code. Part of this need for quality resides in the difficulty of debugging at scale and part is due to flaws that are exposed in the parallelism process or simply due to the sheer number of iterations that each line of code is executed. Perhaps this is because the probability of encountering a flaw is quite small, but when a thousand processors are running the code, it becomes a thousand times more likely to occur.

- The profiling step is important to determine where to focus optimization and parallelism work. Chapter 3 provides more details on how to profile your application.

- There is an overall project plan and another separate plan for each iteration of development. Both of these plans should include some research to include mini-apps, data structure designs, and new parallel algorithms to lay the foundation for the next steps.

- With the commit step, we need to develop processes to maintain good code quality. This should be an ongoing effort and not pushed to later when the code is put into production or when the existing user base starts encountering problems with large, long-running simulations.
