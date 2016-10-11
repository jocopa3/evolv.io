// Typical Worst case scenario: 15% improvement (rendering 1000 soft bodies plus 90% of tiles)
// Typical Best case scenario:  96% improvement (zoomed in all the way)
// Average Usage:               77% improvement (using both keyboard and brain control with default zoom levels)

// Profiling programs is important; it shows what needs the most improvement and what can be ignored
// In this case, rendering was an absolute mess taking up 95% of the frame time and thus was the 
// main focus for optimization.

// These optimizations reduced rendering down to ~84% of the frame time, and it reduced
// the total frame time from over 110ms per frame to between 10ms and 80ms per frame
// depending on the zoom level, playback speed, and number of creatures

// Note: all measurements were taken on my laptop. I'm confident this program would run better on a desktop.