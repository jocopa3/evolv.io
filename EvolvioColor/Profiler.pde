import java.util.*;

/*
 * This class is used to profile the performance of code sections.
 *
 * Call measure to start profiling a section of code
 * Call stop to stop profiling the code between the last call to measure
 * Call reset once per frame to process profiling results and optionally print them
 */

static class Profiler {
  
  // Because the profiler can hinder performance, this option can be used to toggle it on/off
  public static boolean EnableProfiling = false;
  
  public static Profiler profiler = new Profiler(); // Singleton instance to allow for global access
  
  private Stack<Long> startTimes = new Stack<Long>();
  private Stack<String> sections = new Stack<String>();
  
  private HashMap frameTimes = new HashMap();
  private HashMap totalTimes = new HashMap();
  
  // Use a custom frame counter instead of processing's internal
  // frame counter to track how many times reset was called
  private int frameCounter = 0;
  private boolean stackCorrupted = false;
  
  public Profiler() {}
  
  private void Measure(String sectionName) {
    sections.push(sectionName);
    startTimes.push(new Long(System.nanoTime())); // This should be the last line in the function to reduce measured overhead
  }
  
  // Start measuring a section of code
  // sectionName - the name of the section being measured; use something unique for easy reference
  public static void measure(String sectionName) {
    if(!EnableProfiling)
      return;
      
    profiler.Measure(sectionName);
  }
  
  private void Stop() {
    Long stopTime = System.nanoTime(); // This should come first to reduce measured overhead
    
    if(sections.isEmpty())
      return;
      
    String currentSection = sections.pop();
    Long timeSpent = stopTime.longValue() - startTimes.pop().longValue();
    Long totalTime = (Long)frameTimes.get(currentSection);
    
    if(totalTime == null)
      frameTimes.put(currentSection, timeSpent.longValue());
    else
      frameTimes.put(currentSection, new Long(totalTime.longValue() + (timeSpent.longValue())));
  }
  
  // Stop measuring the previously started section
  public static void stop() {
    if(!EnableProfiling)
      return;
      
    profiler.Stop();
  }
  
  private void Print() {
    Set set = frameTimes.entrySet();
    Iterator iter = set.iterator();
    
    Long frameTime, totalTime;
    String key;
    
    ArrayList<String> results = new ArrayList<String>();
    
    set = totalTimes.entrySet();
    iter = set.iterator();
    
    // Go over total times and print stats for each
    while(iter.hasNext()) {
      key = (String)((Map.Entry)iter.next()).getKey();
      
      frameTime = (Long)frameTimes.get(key);
      totalTime = (Long)totalTimes.get(key);
      
      if(frameTime == null)
        results.add(key + ": " + totalTime); // Frame time wasn't updated this frame so ignore it
      else
        results.add(key + ": " + totalTime + ", " + (frameTime/1000000));
    }
    
    // Sort the results in alphabetical order
    Collections.sort(results, new Comparator<String>() {
      @Override
      public int compare(String a, String b) {
        return a.compareToIgnoreCase(b);
      }
    });
    
    // Print the results
    println("Frame: "+frameCounter);
    
    for(String line : results)
      println(line);
    
    println();
  }
  
  // Reset the profiler and prepare for the next frame
  // Should only be called once per frame
  private void Reset(boolean shouldPrint) {
    if(!sections.isEmpty() && !stackCorrupted) {
      print("ERROR: Not every call to measure has a corresponding stop call\nStack: ");
      
      // For debugging purposes, print the sections stack
      for(int i = 0; i < sections.size(); i++)
        print(sections.get(i)+"; ");
      println();
      
      // Clear all values from the current fram as they're likely corrupted
      sections.clear();
      startTimes.clear();
      frameTimes.clear();
      
      // Used ignore duplicate issues happening every frame
      stackCorrupted = true;
      
      return;
    }
    
    stackCorrupted = false;  
    frameCounter++;
    
    // Create a set and an interator used to iterate over the frameTimes HashMap
    Set set = frameTimes.entrySet();
    Iterator iter = set.iterator();
    
    // Declare temporary variables
    Map.Entry entry;
    Long frameTime, totalTime;
    String key;
    
    // Add frameTime stats to the totalTime stats
    while(iter.hasNext()) {
      entry = (Map.Entry)iter.next();
      key = (String)entry.getKey();
      
      frameTime = (Long)frameTimes.get(key);
      totalTime = (Long)totalTimes.get(key);
      
      if(frameTime == null)
        continue;
      
      // If totalTime for the current section is null, set the initial value
      if(totalTime == null)
        totalTimes.put(entry.getKey(), new Long(frameTime.longValue()/1000000));
      else 
        // Add the frameTime to the totalTime and set the totalT
        totalTimes.put(entry.getKey(), new Long((frameTime.longValue()/1000000) + totalTime.longValue()));
    }
    
    if(shouldPrint)
      Print();
    
    // Clear frame time values for next frame
    frameTimes.clear();
  }
  
  public static void reset(boolean shouldPrint) {
    if(!EnableProfiling)
      return;
      
    profiler.Reset(shouldPrint);
  }
}