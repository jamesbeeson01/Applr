## General

- [ ] Overview section: la_01 and la_02 occupy the same table cell
- [ ] Do slice_2d functions borrow from geom_slice.R? Shared functions should probably be separated to its own file
- [ ] autoplot.lm.R line 111-116 matches (loosely) geom_slice.R 192-197. Is autoplot's error check necessary, or just duplicated?

### Test Suite Full Refactor

- [ ] OK is misleading - it does not require a visual check, and it's therefore unknown if a plot regressed because it never gets checked 
    - Possible solution: manual checkoff is required, programmatically reset if a newly rendered plot is not an exact pixel match to the previous
    - Alternative: Must be a pixel-perfect match to the reference image (requires some effort to make very solid references)
- [ ] Most of the expect statments start with a "why" or explanation when they should start with "what" and an optional "why" - it shouldn't re-explain what is visible in the test case code
    - For example: ap_09 should start with "Expect: Scatter plot with one straight line; two console messages"
    - ap_07 does a better job with "Expect: A friendly error telling the user to refit with a data argument, such as 'lm(y ~ x, data = your_data)'"
- [ ] I really like """Specify one of the model's predictors (`x`, `x_pos`), such as 'x_axis = "x"', or an expression of them.""" from s2_16. I wonder if that type of message gets carried to gs_56


### extra - not required:

- [ ] I'd like geom_smooth's y-transform (and some other tests) to more frequently use no errors/noise. It's a lot easier to diagnose that way.
- [ ] back_transform is a deep module. Instead of testing all of its function with every chart that uses it, just test it once per chart and have a full testing section just for it (not ready to implement that yet - needs a little thought on my part)
- [ ] gs_38 isn't a pixel-perfect match with the reference. geom_slice has the right output, the reference is slightly off. Same with gs_39

I like that there are console and visual types for test cases. Console type cases communicate that the agent doesn't need to make a visual comparison. It just needs to read and compare the console output and know whether or not the plot rendered (not sure if that is currently in the implementation). Even when it isn't an error case, there are some cases that are just testing a message, and the plot doesn't need to be viewed or compared against. Visual, of course, needs to compare (and I think some tests compare both output and plot). However, I only like that distinction because it saves on context when the agent doesn't have to look at the images. When it comes to human viewing in report.Rmd, I want to see the plot even if it's a console case. It's cheap for me to look at the plot, and reassuring. In that sense, there isn't really a difference between the two types of cases. Also, when it is an error case, I still want some cue that the plot didn't render. I don't think this is a huge testing suite change, but it would be valuable to me. So let's keep the signal for the agent, but treat everything the same for humans (keeping the naming for files is fine).


