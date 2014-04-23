CREATE TABLE IF NOT EXISTS POSTS (ID INTEGER PRIMARY KEY AUTOINCREMENT, POSTID TEXT UNIQUE, SUMMARY TEXT, CATEGORY TEXT, TITLE TEXT, CONTENT TEXT, METADATA TEXT, SOURCE TEXT, READCOUNT INT DEFAULT 0, ISFAVORITE INT DEFAULT 0, ISVOTEUP INT DEFAULT 0, ISVOTEDOWN INT DEFAULT 0);

INSERT INTO POSTS (POSTID, CATEGORY, SUMMARY, TITLE, SOURCE, CONTENT, METADATA) VALUES ("05c1830b02f750851926733f2316acef", "cloud", "", "Design a site similar to tinyu... | CareerCup", "http://www.careercup.com/question?id=14578080", " Design a site similar to tinyurl.com

-  Steve  on September 12, 2012
 Everytime when a url is to be shortened, url_id field is incremented, url_id is converted to base-36 ( 26 alphabets + 10 digits ) OR base-62 ( 26 small alphabets + 26 capital alphabets + 10 digits ) which serves as primary key for each tuple.  A string i.e. the actual url is added corresponding to this key in database. The primary key is appended to service providers domain name after '/' and returned to the user.

Usually its better to add a new url_id rather than searching for existence of a url in database. So same url can be shortened to multiple short url's.

But some sites do take care of not adding multiple short url's in database if same user try to reproduce it. They consider user location for this purpose.

- Cerberuz on September 13, 2012
 If people think allowing same url to map to multiple IDs might lead to a (D)DOS attack, consuming the id space, think again.

- Anonymous on September 13, 2012
 DDOS attack is a different thing, i think the service provider takes care of such things when considering multiple ids for same url ( complete consumption of id space is a rare case, DDOS attack will have to be of huge order and extremely fast to do that ). Moreover i already specified that some sites don't add multiple id's for same url e.g tinyurl while some sites do e.g google url shortener.

- Cerberuz on September 13, 2012
 @Cerebruz:  That comment seems to be in support of your answer, isn't it?

- Anonymous on September 13, 2012
 Little more info from google URL shortener :  The Google URL Shortener provides different functionality based on whether or not you are signed in:
: If you are signed in to goo.gl using a Google Account, a unique short URL is generated each time a long URL is shortened.
: If you are not signed in to goo.gl, the same short URL is reused each time a long URL is shortened, across multiple users

- Cerberuz on September 13, 2012
 use hashmap,

break url in 2 portion, one is the domain name part and other is rest one,

now apply hashfunction on both separately and concatenate them,(this will reduce chance of collision).

if the given url is already used then return the previously used hash value.

- niraj.nijju on September 13, 2012
 I guess we can apply hashmap funda here............take the sitename as input to hasfunction ...the output of the hashfunction is your tinyURL and map it to the IP address in the hashtable..... :-/

- Mukesh Kumar Verma on September 12, 2012
 What if two tiny URL point to same link.. How will you handle that case..

- loveCoding on September 13, 2012
 why not return the already present hash value?
", "metamodifytime=1397497065&edited=1&favorite=0&meatamodifytime=1398258603&voteup=1&modifytime=1398177799&votedown=0&datamodifytime=1397497065");
INSERT INTO POSTS (POSTID, CATEGORY, SUMMARY, TITLE, SOURCE, CONTENT, METADATA) VALUES ("60837d7f543e8b11a578e995e5a4ff39", "cloud", "", "Code a distributed hash table ... | CareerCup", "http://www.careercup.com/question?id=14491787", " Code a distributed hash table that will always live on 3 machines. Optimize for the case where the 3 machines are virtual on a single physical machine and when they are 3 physical machines.

- edoc0code  on August 08, 2012
 Unfortunately, could not code or optimize this properly. My solution involved a very simple sharding of the hash table by modding the kv hash by the node-id. I believe the interviewer was not very satisfied with the approach.

- edoc0code on August 08, 2012
 Sharding is an appropriate solution for a situation like this where there's a fixed number of machines.  nodeNumber = hash % numberOfNodes;

- Anonymous on August 08, 2012
 Even load balancing is more important if you have physical machines because each machine will have a separate hard disk. So then you might want to invest in additional features like either using a secure hash function to ensure that it's very likely the distribution is even, or implementing some sort of re-balancing mechanism.

- Anonymous on August 08, 2012
 How can we optimize this for the case when the 3 virtual machines reside on the same host?

- Anonymous on August 11, 2012
 Use consistent hashing, Anyway how does it matter if the VM's are running on the same host or different hosts? You basically need to take care of the case when the number of nodes change and I think consistent hashing should do the trick here
", "metamodifytime=1397497065&edited=1&favorite=0&meatamodifytime=1398258603&voteup=1&modifytime=1398177799&votedown=0&datamodifytime=1397497065");
INSERT INTO POSTS (POSTID, CATEGORY, SUMMARY, TITLE, SOURCE, CONTENT, METADATA) VALUES ("b53250ee0f8c6d5b356aa2e287e19df2", "cloud", "", "Design an architecture for RES... | CareerCup", "http://www.careercup.com/question?id=4802170184531968", " Design an architecture for REST APIs where you have to upload big data like images/videos etc. Request should be async. Follow up: How will you tune the performance if you have millions of requests coming at same time? Clues: Queueing the request, Storing data in filesystems rather than traditional DB etc.

-
", "metamodifytime=1397497065&edited=1&favorite=0&meatamodifytime=1398258603&voteup=1&modifytime=1398177799&votedown=0&datamodifytime=1397497065");
INSERT INTO POSTS (POSTID, CATEGORY, SUMMARY, TITLE, SOURCE, CONTENT, METADATA) VALUES ("f94dace0eb07927f0faf210e3afcc0d7", "cloud", "", "large file(can't fit into memo... | CareerCup", "http://www.careercup.com/question?id=13218749", " large file(can't fit into memory) with multiple lines, how to get any line in equal probability

- Itcecsa  on April 16, 2012
 See reservoir sampling on wikipedia

-  Ashupriya on July 03, 2012
down vote
You can do this without having to read all the lines in memory, thus working well for huge files. Pseudocode:

linenum := 0
ret := ''
while more lines to read:
  line := readline()
  linenum := linenum + 1
  r := uniform_random(0, linenum)
  if r

- Unknown on April 16, 2012
 In the book 《programming pearls》 second edition, the 12th capter and the 10th question in the exercise. At last, the probabilty to choose any line is 1/n.
when there are n lines. the probabilty to choose n - 1line is 1 / (n - 1) * (n - 1) / n = 1/ n
the probabilty to choose n - 1 * the probability not choose n.

-  milo on April 16, 2012
 @milo...can u plz eleborate on the solution...i couldnt get how we can always achieve the equal prob....
Thankx

-  candis on April 16, 2012
 @candis the probability to choose n - 2 line when there are n lines in the file is: 1 / (n - 2) * (n - 2) / (n - 1) * (n - 1) / n = 1 / n. and so on, for any line, the probability is 1 / n.

-  milo on April 17, 2012
 @candis we should make distinction between the probability of read a line and the probability of get a line.
The probability of get a line = the probability of read a line * the probability not read the lines after the current line

-  milo on April 17, 2012
 If there are 2 lines, probability of choosing one line is 1/2. If there are 5 lines then the probability of choosing one line is 1/5. If there are n lines, then the probability of choosing one line is 1/n. So there is an equal probability.

But the question here is how to get this programatically?

- roopesh on May 13, 2012
 A practical solution:
)Count lines (tot_line) in largefile.txt and record file offset in an array (if memory allows), or binary disk file offset.dat, while contains file offset(int64).
) Generate random line number randline = randf()*tot_line.
) If in memory, directly access array using randline-1 as index
Directly seek into offset.dat by (randline-1)*8 bytes, retrieve line offset offset_val.
) Seek into largef.txt by offset_val bytes.
) Read line.

- jzhu on May 18, 2012
)  Scan the file using readline()  and note the offset of each line by writing it in binary to a 32 bit unsigned int in a new someseperatortablesomeseperator file (or better yet in RAM if it fits).  Keep a count of how many lines you encounter.
)  Generate a random number up to number of lines.
)  Seek into your binary table file using the line number, and then read the offset, then seek into the big file and get the line.
O(n) where n is number of chars in big file, can't avoid that.  Each lookup is a fairly small constant.  If number of items in table fits in memory, you get a speedup.

- wealthchef on June 07, 2012
 Divide the file in N chunks, of 10,000 (e.g.) lines each
store the offset of these N chunks in another file / in memory.
For the last chunk, also count the line numbers (Let say have K line) in it, if it is less than 10,000 then store this information as well

Generate a number randomly between 1 to N, and open this chunk, by seeking to that position in that file.

Now generate another number between 1 and 10,000 and return taht line,
in case of the last chunk generate the number between 1 and K, and return that line....
", "metamodifytime=1397497065&edited=1&favorite=0&meatamodifytime=1398258603&voteup=1&modifytime=1398177799&votedown=0&datamodifytime=1397497065");
INSERT INTO POSTS (POSTID, CATEGORY, SUMMARY, TITLE, SOURCE, CONTENT, METADATA) VALUES ("b85aaa8f3de86df284fcf963c4a0012a", "cloud", "", "Given a very long list of URLs... | CareerCup", "http://www.careercup.com/question?id=11856466", " Given a very long list of URLs, find the first URL which is unique ( occurred exactly once ).

I gave a O(n) extra space and O(2n) time solution, but he was expecting O(n) time, one traversal.

-  AK  on December 06, 2011
 you can solve this in O(n) using a combination of trie and linked list. The leaf node of a trie maintains a flag to record duplicate urls and pointer to a node in a link list. If you encounter a new url, add a node to the head of the linked list and set the pointer in the trie. Whenever you encounter a url that is already in the trie, if the flag is not set, then set the flag, delete the node from the linked list and set pointer to null. If the flag is already set, then ignore and read the next url.
After processing all the urls, the link list should only contain the unique urls and the node at the tail is the first unique url from the list. For n urls, inserting urls into the trie in O(n) and link list operations are all constant time. The node could just keep the index of the url in the list so that we don't have to store urls in the link list as well.

- hello world on December 14, 2011
 i thought tries have insertion time o(nlogn) for n elements. are you sure its o(n), its a tree structure...

- andy on February 29, 2012
 The trie insertion time is k, where k is the length of the string being inserted.  So the total time is O(nk).  Since the length of the URL's doesn't depend on n, though, and can be expected to be relatively constant, this is O(n).

- Anonymous on March 25, 2012
 Why not just use a hashtable if your storage is going to be O(n) anyway though?

- Anonymous on March 25, 2012
 Storage is going to be O(n) -- but a hash table is not as space efficient as it has to store the entire string in case of collision, but in all partial matches are collapsed together, no?

- wealthychef on June 17, 2012
 Incorrect soln will not be O(n) as you would be deleting nodes from link list...parsing till node will be extra time.

- on November 03, 2012
 To answer the question of above user:
There is no extra time needed to someseperatorparse till the node to be deletedsomeseperator.
The following code is my implementation of the same idea as that of the original poster,
the linked list is combined with the trie,
once you have finished travelling to end of an url in the trie,
you would have the node in the linked list to be deleted.  /* The fields 'parent' and 'child' are for the trie.
 * The fields 'prev' and 'next' are for the linked list.
 * I presume that the character-set of URL is {'a' - 'z', '.', '/', ':'}.
 * In real interview, need to discuss the assumption with your interviewer.
 */
class Node
{
 public Node parent = null;
 public Node[] child = new Node[29];
 public Node prev = null;
 public Node next = null;
 public char data = ' ';
 public int count = 0;
}

class G105
{
 public static String firstUnique(String[] array)
 {
  Node root = new Node();
  Node first = null;
  Node last = null;
  for (String s : array)
  {
  Node current = root;
  /* Modify the trie */
  for (char c : s.toCharArray())
  {
  int index = 0;
  if (':' == c) {index = 28;}
  else if ('/' == c) {index = 27;}
  else if ('.' == c) {index = 26;}
  else {index = c - 'a';}

  if (null == current.child[index])
  {
  Node next = new Node();
  next.parent = current;
  next.data = c;
  current.child[index] = next;
  }
  current = current.child[index];
  }

  /* Modify the linked list */
  current.count++;
  if (1 == current.count)
  {
  if (null == first) {first = last = current;}
  else
  {
  current.prev = last;
  last.next = current;
  last = current;
  }
  }
  else if (2 == current.count)
  {
  if (current == first)
  {
  first = current.next;
  if (null != first) {first.prev = null;}
  }
  else
  {
  Node prev = current.prev;
  prev.next = current.next;
  if (null != current.next)
  {
  current.next.prev = prev;
  }
  }
  }
  }

  StringBuffer sb = new StringBuffer();
  Node current = first;
  while (current != root)
  {
  sb.append(current.data);
  current = current.parent;
  }
  return sb.reverse().toString();
 }

 public static void main(String[] args)
 {
  String[] urls = {
  someseperatorabc.google.comsomeseperator,
  someseperatorabc.facebook.comsomeseperator,
  someseperatorabc.amazon.comsomeseperator,
  someseperatorabc.yahoo.comsomeseperator,
  someseperatorabc.facebook.comsomeseperator,
  someseperatorabc.yahoo.comsomeseperator,
  someseperatorabc.facebook.comsomeseperator,
  someseperatorabc.google.comsomeseperator
  };
  System.out.println(firstUnique(urls));
 }
}

-  Alva0930 on February 15, 2013
 I believe you used hash(or trie or something similar) to store the counts of each URL.
To make it one traversal, you need only to use a doubly linked list to link all the unique ones (either link the items in the hash table or do it separately) so far as you traverse through.
Remove the URL from the list if its count goes over 1;
and of course connects its predecessor and successor (which is actually implied when I say someseperatorremovesomeseperator)
So after one traversal, the first one of your linked list is the desired one.
Extra spaces for two pointers for each URL are required for this solution.

- fentoyal on December 07, 2011
 suppose you are in the middle of traversing thru the list, u have a half prepared link list, now u get another url, so what u do?? u traverse thru the link list untill u find the match. But how u r going to do this someseperatortraverse thrusomeseperator for each element on someseperatoroverall O(n) complexitysomeseperator??

- Anonymous on December 07, 2011
 The doubly linked list is in addition to the hash table.To remove or to insert a node to this list is up to the count of the URL in the hash table.

- fentoyal on December 09, 2011
 If we have a hash table then why do we require a linked list. Can't we just traverse the array and keep on checking the count for each one??

- R on January 30, 2012
 You may consider an array is a special type of hashtable which integrates (partly) the doubly linked list. But in practice, I believe a real hast table is required and each of its item is pointing to a doubly linked list.You can tell the difference between these two different models

- fentoyal on January 31, 2012
 What does unique mean? appearing exactly once?

Hash the url and use the hash to check for dupes, should be faster than plain old string matching.

- Sergey Brin on January 30, 2009
 millions of url i dont think hash is a good idea

- anshulzunke on September 18, 2011
 Use min heap with url as data of heap and url_frequency as the heap comparator.
Top of the heap would give u an unique url if its frequency is exactly 1.

O(nlogn) time complexity, O(n) space complexity.

- Sid on January 30, 2009
 Sorry, this doesnt work in O(nlogn).
When we see a duplicated url, to find the url and increase its url_frequency count is O(n) (Searching in heap is O(n))

Hence, the overall time complexity is O(n^2).

- Sid on January 30, 2009
 I think this might work in linear time.
Assign a prime number for each character (letters, digits and special characters). Eg: 'a'--> 2, 'b'-->3, '1'-->17, '#'--> 29. Compute the hash code of the url based on the character's prime number and its position in the url.
After computing the hashcode, insert the hashcode in HashSet (in Java). Do this for every URL. Incase the hashcode of URL mathces the hashcode of some previous url inserted in HashSet, then its the first duplicate.

- badalrocks on February 01, 2009
 If urls are stored in xml file, then a quick way would be to use Muench's grouping technique to retrieve unique url.

- Anonymous on February 07, 2009
 bedalrocks,

Using prime numbers is usually a very bad idea, practically speaking.

-Anonymous on March 10, 2009
 Sort the url list using quick sort in O(nlogn). Scan through the array to find the unique URL in O(n) time. Total time: O(nlogn).

PS: Here sorting and scnaning involves string comparision. Say if each string is length K, we can treat n*k = N as another constant.

-Sadineni.Venkat on April 28, 2009
 The list of url's is very big, and hence sorting does not seem to be a valid option here.

-Kk on May 24, 2011
 what abt md5 checksum

- Anonymous on May 15, 2009
 Seems list quite a few here have missed a part of the question. The question is to find the first unique URL. Not any unique url or the first duplicate.

A solution would be
* go through the URLs, store in hash table, for key=url, a boolean value that represents if the URL has been seen once or more than once. That is first pass.
* go through the URLs again, and for each URL, check in the hash table, for how many times it has occured. If it has occured only once, that's the URL you want.

Now, there are some space constraints that I haven't considered. Millions of URLs. Let's say 10 million URLs. Each URL has let's say 50 characters on average. That's 500 million characters. That takes up a lot of space even though it is doable. However if I am using a hash table, I am not storing the entire URL, but just the hash code and a boolean. That would be let's say 4 bytes for hash code and a bit for boolean. ~40 MB for hash table. That's not bad at all.

One way to optimize the second pass would be .. if I could create another array that contains the URLs in the order in which they appear in the original list, however without any duplicates. I can construct this during the first pass. So during the second pass, I could go through this array, that way reducing the number of URLs I am processing. However this needs additional memory.

Now if I could make this more challenging, what if the number of URLs is not millions but billions. In that case the hash table cannot be stored in memory. It would be in the order of 40GB. How would we solve the problem then?

One solution I can think of is to use distributed computing. Have multiple server machines store the hash table pieces in their local memory. Since network communication could be faster than disk reads, this could work well. Otherwise ", "metamodifytime=1397497065&edited=1&favorite=0&meatamodifytime=1398258603&voteup=1&modifytime=1398177799&votedown=0&datamodifytime=1397497065");
INSERT INTO POSTS (POSTID, CATEGORY, SUMMARY, TITLE, SOURCE, CONTENT, METADATA) VALUES ("8ef5ebe31e4647361dd7b5bd93605073", "cloud", "", "If there are 1 million files i... | CareerCup", "http://www.careercup.com/question?id=13424662", " If there are 1 million files in Amazon database, there is a wrong area code of customer phone number. How would you debug?

- terryocy  on April 27, 2012
 The question states _files_. No mention of indexes created etc. So it seems more like a question of scripting, like perhaps using grep...

- Anonymous on May 02, 2012
 I would start with asking questions to see what information is available to narrow the search.

. Is there a city, state or zip code saved for customers
. Can we assume that their area code is correct in correlation with their location
(i.e within which # range can we check their area code? to their zip code, city or state)
. We have accesses to a list of the valid area codes for the location rage.

For my solution these have to be true, which is completely realistic for a shopping site. Further more if we are only looking at lan line number, and not a cell, we most likely won't have the issue of number 2.

From here you would do database queries to pull all customer ids and numbers from each zip code, city or state. Next you cycle through all the customers area codes until one comes up does not match the list of valid area codes given by assumption 3.

If you do not have access to 3, then for each location query (zip, city, or state) you just have to keep a hash table where the area code is the key and the value is how many customers had it for that area. Then at the end you just find the key that has a value of 1, meaning that only one customer in the that location had that area code.

- Guessing on April 27, 2012
 but there is 1 millions files so i don't think hash will help .. how we will fetch these files into memory. and what datstructure we should use for this.what would be size of DS?

- Anonymous on April 30, 2012
 The assumption here is that by breaking down the search area we aren't dealing with all the files at once. Doing a hash map for each (state, city or zipcode), wouldn't be large at all. There are only 25 area codes for California, and only 21 for Texas. All you are doing is cycling through DB entries and checking the number. So you do a query like:

someseperatorSELECT id, number
FROM millionFiles
WHERE state = {$state}someseperator;

Then cycle through the entries given back by the query, by using mysql_fetcharray() in php.

So you would basically have 2 nested for loops where the top would cycle through countries, the next through the states of that country. And for each query you ran for the state, you would cycle through the results and populate the hash. Then when the last person is checked from the results, and added to the hash, check the hash for a value of 1. If it exists, that is the possible area code that is wrong.

If you are doing a global search where you want to test all numbers for every country, regardless of the first singleton area code was found. Then I would create a data structure for saving the id, and area code for each time the value of 1 is found in the hash, after the state area code loop. You are creating a hash each time a new state is looped through, then discarding it once the loop is finished.

On the other hand instead of just adding all area codes to the hash and incrementing, you could just check to see if each individual in the result had an area code that was in the list of valid area codes for that state. As soon as an area code is hit that does not match up to the valid area codes of that state, you have your match.
", "metamodifytime=1397497065&edited=1&favorite=0&meatamodifytime=1398258603&voteup=1&modifytime=1398177799&votedown=0&datamodifytime=1397497065");
INSERT INTO POSTS (POSTID, CATEGORY, SUMMARY, TITLE, SOURCE, CONTENT, METADATA) VALUES ("d452ba12f3641d80f20fea17f603878a", "cloud", "", "In a very complicated Java bac... | CareerCup", "http://www.careercup.com/question?id=416293", " In a very complicated Java back-end system, since the load is too big, the garbage collector can not handle the memory and start having memory leaks. How to detect it and solve it?

- nixu09  on March 01, 2010
 Chk this out:-

www[dot]ibm[dot]com/developerworks/library/j-leaks/index[dot]html

- Anonymous on October 28, 2011
 Looks like you have no idea why someseperator[dot]someseperator is used instead of normal someseperator.someseperator :)

- Anonymous on June 30, 2013
 determine life-cycle of objects,
short term objects are managed by internal memory manager(like pool) not allocated java new?

- Zaphod on March 03, 2010
 Could you elaborate?

-  nixu09 on March 03, 2010
 Cant we use a profiler, say JProbe?. It could be possible that they were testing whether a candidate is aware of such tools
", "metamodifytime=1397497065&edited=1&favorite=0&meatamodifytime=1398258603&voteup=1&modifytime=1398177799&votedown=0&datamodifytime=1397497065");
INSERT INTO POSTS (POSTID, CATEGORY, SUMMARY, TITLE, SOURCE, CONTENT, METADATA) VALUES ("6742c5eb30b6adcd955c9f0ef9cc73f9", "cloud", "", "How would you design and imple... | CareerCup", "http://www.careercup.com/question?id=12014791", " How would you design and implement a large social network's (G+ or fb) friend recommendation system ?

- P  on December 08, 2011
 For each node in the FB graph, first find all nodes which can be reached with a path of length 2 from our node. These represent friends of friends nodes. For our nodes, sort these nodes list by the maximum no of paths of length 2 via which we can reach a node. Say that I have 5 nodes in the list which I can reach via a path of length 2 from my node. Now, if I can reach one of these nodes(say 'C') via 6 different 2-paths, that means that C and I share 6 mutual friends. This node is given the highest priority of recommendation.

But, I think this way, we'll be storing way too much information for each and every node......a sorted list for each node....the length of which can go to thousands......

- Anonymous on December 11, 2011

 We can calculate the 2nd order of the adjMatrix, this would not only give the paths of length 2 but also the No of 2-length paths possible between i and j....

- Ashupriya on July 02, 2012
 hmm.

For just Friends of Friends..

Do a BFS with slight change
when you reach a visited node again, instead of ignoring just increment the count, which indicates common friends. Keep a top 100 Priority Queue and keep adding whenever the count is more than the smallest in the queue.

Add other weightage factors now like,
same (ex-)company, same school, common group, same city etc.

- Anonymous on December 21, 2011
 Could this algorithm create an infinite loop?
Say a has a friend b who has a friend c who has a friend a.

- someone on December 26, 2011
you only need to go to 2 levels deep, there should be no loop.

- bloggans on January 23, 2012
 also if c is a frnd of a, a is frnd of a too,indirect graph, so it will discovered at first and no loop

- Mohit on April 05, 2012
 Hadoop it. Where Map is a query:
select T1.Friend from T as T1 where T1.Person in {select T2.Friend from T as T2 where T2.Person = someseperatorNamesomeseperator} and T1.Person != someseperatorNamesomeseperator.  The reduce function is the Union Function.

- Anonymous on December 08, 2011
 It seems like graph problem.
) Check if one node can be reached(friends) from more than one node then that will be highly recommended node.
) Friend of friend will next recommendation. (Less priority than first).

Graphs can be made for one person in many ways.
) Based on names.
) Based on places.
) Based on schools.
(All Parameters like places etc.)
", "metamodifytime=1397497065&edited=1&favorite=0&meatamodifytime=1398258603&voteup=1&modifytime=1398177799&votedown=0&datamodifytime=1397497065");
INSERT INTO POSTS (POSTID, CATEGORY, SUMMARY, TITLE, SOURCE, CONTENT, METADATA) VALUES ("3d9cbb984602fe69668a199d0df2aa8e", "cloud", "", "How does DropBox work ? Say if... | CareerCup", "http://www.careercup.com/question?id=17782663", " How does DropBox work ? Say if you have 25 Gb space granted to you by DropBox, does it mean that DropBox application when installed on Desktop will allocate 25 GB of your space ? Or does it keep only the recent used files on system and METADATA for all the files. Please suggest.

-  shridhar.swapan  on April 25, 2013 in United States
 DropBox works on the principle of Cloud Computing meaning all the data you uploaded will be stored in the HUGE Server and also on the application from where you have uploaded.( Say from your desktop etc) Once, you downloaded it, the same thing happens, It won't get delete until U manually delete it by yourself.

- hprem991  on April 25, 2013
 One huge server? Its more like thousands of servers..

- HugeServer on September 26, 2013 it is just a quota based system. The actual allocation happens when you add files to your quota. The storage expands and collapses automatically, based on your current usage.

- whitenoise on April 25, 2013
 The data is virtual until demand to use them; they are allocated in cloud system, in depth, they have been sliced, and stored onto many servers; managed by some kind of index servers.

-Ian F. on April 26, 2013
 Idk man i don't speak english

- Allen Vo. on April 26, 2013
 But, if there is a 25 gb file, is all of that stored in my drive ?!

- Anonymous on April 27, 2013
Yes u r rit for the first time when ur uploading the file u have to upload from ur system bt after uploading ur data store to cloud now u r free to delete the data.hence the meta data of the cloud of ur data is saved in dropbox folder in ur system,so when ever u need u can use that link and download that to ur local system. :)

- go4gold on April 29, 2013
 Off course later - It keeps only the recent used files on system and METADATA for all the files.
", "metamodifytime=1397497065&edited=1&favorite=0&meatamodifytime=1398258603&voteup=3&modifytime=1398177799&votedown=0&datamodifytime=1397497065");
INSERT INTO POSTS (POSTID, CATEGORY, SUMMARY, TITLE, SOURCE, CONTENT, METADATA) VALUES ("f03c3a7adf7db9dfd8fbb97c29a1b06d", "cloud", "", "In your application, why datab... | CareerCup", "http://www.careercup.com/question?id=14414732", " In your application, why database (story history) is used at client side and not on server side ?

- Sachin  on July 24, 2012
 I think, these type of application are generally monitoring tools.  When some services or processes running on client machine the data is stored in data base and can be synch with server to be shown on other machine or users.
", "metamodifytime=1397497065&edited=1&favorite=0&meatamodifytime=1398258603&voteup=1&modifytime=1398177799&votedown=0&datamodifytime=1397497065");
