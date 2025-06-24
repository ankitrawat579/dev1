public with sharing class uniqueReturn {
    public static Set<Integer> testReturn(Integer one, Integer two, Integer three, Integer four, Integer five) { 
        Set<Integer> recList = new Set<Integer>();
        recList.add(one);
        recList.add(two);
        recList.add(three);
        recList.add(four);
        recList.add(five);
        
        system.debug('testOne?? '+recList);
        return recList;
    }
}