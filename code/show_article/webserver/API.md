XiaoZibao--Webserver API
=========

## API List
=========

- [API of Posts](#api-of-posts)
  - [Get topic list] (#get-topic-list)
  - [Get posts in a topic] (#get-posts-in-a-topic)
  - [Get topic by id] (#Get-topic-by-id)

- All API conform to HTTP GET/POST
- The data format is mostly json.

$server is server ip, $port is server port.

## API of Posts
=========
### Get topic list
`GET: http://$server:$port/api_list_topic`

_Sample Request_

    bash-3.2$ curl "http://$server:$port/api_list_topic"
    concept,product,linux,algorithm,cloud,security
    
---

### Get posts in a topic
`GET: http://$server:$port/api_list_posts_in_topic`

| Parameter   |Required | Desc|
:-----------|------|------------------------------------------------------------------------------|
| topic  |Y  | topic name |
| start_num  |N  |  |
| count  |N  |  |

_Sample Request_

    bash-3.2$ curl "http://$server:$port/api_list_posts_in_topic?topic=concept&start_num=0&count=10"
    [
    {"id":"fdce06044a839c40df0ca5cb79ff3c00","category":"concept","title":"Why is java secure? | CareerCup","summary":""},
    {"id":"f90aeb6d01d212fa0a0dd7e07a9f17b4","category":"concept","title":"If a variable is a Global Vari... | CareerCup","summary":""},
    {"id":"c324dbf5086be1e516ead4136e79caeb","category":"concept","title":"Explain how congestion control... | CareerCup","summary":""},
    {"id":"ba49f1095cd18a161254e8b4c36f9af4","category":"concept","title":"what is object reflection in J... | CareerCup","summary":""},
    {"id":"b771a22acaa6ac278d5e6275cba940d3","category":"concept","title":"Explain the following terms: v... | CareerCup","summary":""},
    {"id":"4b64b61cff6d10d6d60236fea8316ace","category":"concept","title":"What is synchronized in Java? | CareerCup","summary":""},
    {"id":"0109f18c771cefec7d23f51e1f42dda0","category":"concept","title":"Data Structures: Time complexi... | CareerCup","summary":""},
    {"id":"b3b84f062816979ec2ce1d2ae94211cb","category":"concept","title":"1st interview continued: e ask... | CareerCup","summary":""},
    {"id":"8b425c921fccbbbd51a232aa9387b5e2","category":"concept","title":"What's the size of a empty cla... | CareerCup","summary":""},
    {"id":"afbb77f6c4e15c991b91ad2bcf745228","category":"concept","title":"Java: Differentiate between fi... | CareerCup","summary":""}]

---

### Get topic by id
`GET: http://$server:$port/api_get_post`

| Parameter   |Required | Desc|
:-----------|------|-----------|
| id  |Y  | post id |

_Sample Request_

    "source":"http://www.v2ex.com/t/49317"}bash-3.2$ curl "http://$server:$port/api_get_post?id=4083b529eee6cddf53c71d9eb36a0288"
    {"id":"4083b529eee6cddf53c71d9eb36a0288","category":"algorithm","title":"Given a list of unsorted numbe... | CareerCup",
    "summary":"",
    "content":"\n\n  Software Engineer / Developers\n\n Given a list of unsorted numbers, can you find the numbers that have the smallest absolute difference between them? If there are multiple pairs, find them all.\n\nSample Input\n\n-20 -3916237 -357920 -3620601 7374819 -7330761 30 6246457 -6461594 266854 -520 -470\nSample Output #2\n\n-520 -470 -20 30\nExplanation\n(-470)-(-520) = 30- (-20) = 50, which is the smallest difference.\n\n-  dn_coder  on November 30, 2013 in India\n\n Amazon\n\n Software Engineer / Developer\n\n Algorithm\n\n Country:  India\n\n Interview Type:  Written Test\n\n)first sorting the list\n)traversing the list and return the min absolute pair.\nthe time complexity is O(nlogn).\nI do not know if there is any solution in O(n) steps.\n\n-\n Jason\n on November 30, 2013  Edit  |  Flag\n\n Lookup element distinctness problem and you will get an answer for your last sentence.\n\n-\nSubbu.\n on November 30, 2013  Edit  |  Flag\n\n Subbu - I don't get how the element distinctness problem helps solve this question , can you elaborate? Thanks.\n\n-\nManoj\n on December 01, 2013  Edit  |  Flag\n\n @Jason: there is no O(n) solution for this as subbu mentioned by referring you to 'element distinctness problem'.This problem is just to prove the point that there can't be O(n) solution possible for this problem.\n\n-\naka\n on December 02, 2013  Edit  |  Flag\n\n @aka, @Subbu, thank you for the proof.\n\n-\n Jason\n on December 02, 2013  Edit  |  Flag\n\n O(nlgn) solution:  public static List  getMinDiff(int[] A)\n{\nArrayList  pairs;\nint minDiff = Integer.MAX;\n\n  A=quicksort(A);\nfor(int i=0;i ();\npairs.add(new Pair(A[i], A[i+1]));\nminDiff = abs(A[i+1]-A[i]) ;\n}\nelse if (abs(A[i+1]-A[i]) == minDiff)\n{\npairs.add(new Pair(A[i], A[i+1]));\n}\n}\n\nreturn pairs;\n}\n\n-\n zahidbuet106\n on December 10, 2013  Edit  |  Flag\n\n Ambiguous question.\n\nIf array is all 1. Do we print n(n-1)/2 pairs? or just 1?\n\n-\nAnonymous\n on November 30, 2013  Edit  |  Flag\n\n Using this method we can find the absolute minimum difference:\n\nAssume numbers are array a[ ].  for(int i=1;i max)\n  max=a[i];  }\n\nafter finding absolute min we can get the elements using start and end.\n\nbut since we need to find all. After getting the absolute minimum we will traverse the liist and find out two numbers having difference equal to absolute min.\n\n-\n Nascent\n on November 30, 2013  Edit  |  Flag\n\n I agree with Jason.  First sort the list, then compute the min of  a[i]-a[i-1]\nfor i = 1 to n-1  where a is the array of numbers (sorted).\n\n-\n jarflores\n on December 01, 2013  Edit  |  Flag\n\n> Convert all numbers as positive integers.\n> Sort them. complexity O(n log n) Average/best time\n> Traverse once to find the closest two adjacent numbers. O(n)\nOverall complexity O(n log n)\n\n-\ncode\n on December 01, 2013  Edit  |  Flag\n\n Kindly Ignore this.. not going to work with -20,30\n\n-\nAnonymous\n on December 01, 2013  Edit  |  Flag\n\n Sorry, above won't work for -20,30\n\n-\nCode\n on December 01, 2013  Edit  |  Flag\n\n Solution written in C++. Time complexity O(nlogn).\n\nOutput:  -470 - -520 = 50\n - -20 = 50  Code:  #include\n#include\n#include\n#include\n\nstd::vector > find_min_abs_diff(std::vector & arr) {\n// Sort the vector O(nlogn)\nstd::sort(arr.begin(), arr.end());\n\n// Find the difference between every adjacent elements. O(n)\n// Keep track of minimum\nint min_so_far = std::numeric_limits ::max();\nstd::vector > pairs;\n\nfor (size_t i = 1; i  & p) {\nreturn p.first - p.second > min_so_far;\n}), pairs.end());\n\nreturn pairs;\n}\n\nint main() {\nstd::vector  arr{-20, -3916237, -357920, -3620601, 7374819, -7330761,\n, 6246457, -6461594, 266854, -520, -470};\nstd::vector > min_pairs = find_min_abs_diff(arr);\nfor (const auto& p: min_pairs) {\nstd::cout\n\n-\n Diego Giagio\n on December 01, 2013  Edit  |  Flag\n\n In c#, maybe not the most elegant, but this should work:  using System;\nusing System.Collections.Generic;\nusing System.Linq;\nusing System.Text;\nusing System.Threading.Tasks;\n\nnamespace InterviewQuestions\n{\n  struct pair\n  {\n  public int first;\n  public int second;\n  }\n\n  class Program\n  {\n  static void Main(string[] args)\n  {\n  int[] arr = { -20, -3916237, -357920, -3620601, 7374819, -7330761, 30, 6246457, -6461594, 266854, -520, -470 };\n  int nSmallest = Int32.MaxValue;\n  List  results = new List ();\n\n  for (int i = 0; i\n\n-\nTC\n on December 02, 2013  Edit  |  Flag\n\n here my solution in O(n log n) time.\n@Diego: i think this might be faster than your algo...since i dont call vector.erase...which allocates the vector new?  #include\n#include\n#include\n#include\nusing namespace std;\n\ntypedef struct mypair {\n  int x;\nint y;\nmypair(int x_, int y_): x(x_), y(y_) {}\n}mypair;\n\nvector  get_numbers_min_diff(vector  &vec) {\nmap > m;\n\n// O(n log n)\nsort(vec.begin(), vec.end());\n\n// O(n log n)\nfor(int i = 0; i  v;\nv.push_back(mypair(vec[i], vec[i+1]));\nm.insert(make_pair(diff, v));\n}\nelse {\nit->second.push_back(mypair(vec[i], vec[i+1]));\n}\n}\n\nauto it = m.begin()->second;\n\nreturn it;\n}\n\nint main() {\nvector  vec = {-20, -3916237, -357920, -3620601, 7374819, -7330761, 30, 6246457, -6461594, 266854, -520, -470};\n\nvector  sp = get_numbers_min_diff(vec);\n\nfor_each(sp.begin(), sp.end(), [](mypair p) { cout\n\n-\nGerald\n on December 04, 2013  Edit  |  Flag\n\n O(nlgn) with O(1) space solution\n. Sort the array.\n. Scan the sorted array from left to right. keep minDiff to contain the min difference between two elements during the scan.\n. If diff between two consecutive is less than minDiff so far then create a list and add the pair.\n. if diff between two consecutive is equal to minDiff that means there is already a list. Add the pair to the list.  public static List  getMinDiff(int[] A)\n{\nArrayList  pairs;\nint minDiff = Integer.MAX;\n\n  A=quicksort(A);\nfor(int i=0;i ();\npairs.add(new Pair(A[i], A[i+1]));\nminDiff = abs(A[i+1]-A[i]) ;\n}\nelse if (abs(A[i+1]-A[i]) == minDiff)\n{\npairs.add(new Pair(A[i], A[i+1]));\n}\n}\n\nreturn pairs;\n}\n\n-\n zahidbuet106\n on December 05, 2013  Edit  |  Flag\n\n #include\n#include\n#define MAX 100\nint main()\n{\nint arr[12]={-20,-3916237,-357920,-3620601,7374819,-7330761,30,6246457,-6461594,266854,-520,-470};\nint i,j,temp,c[11],min;\n/* Sort the array*/\n for (i= 0;i arr[j+1])\n  {\n  temp =arr[j];\n  arr[j]=arr[j+1];\n  arr[j+1]=temp;\n  }}}\n\n for(i=0;i c[i])\n  min=c[i];\n\n  }\n  for(i=0;i\n\n-\n harshit1230\n on December 06, 2013  Edit  |  Flag\n\nThis simple python solution is generic in that it will work for any two or single unsorted array...\n\n{{{ from numpy import *\ndef min_diff(a, b):\n  x = array(zip(kron(a, ones(len(b))),kron(ones(len(a)), b)))\n  x = delete(x, where(x[:,0]==x[:, 1]), 0)\n  return int(min(abs((x[:, 0]-x[:,1]))))\n}}\n\n-\naykut\n on December 06, 2013  Edit  |  Flag\n\n.) Sort the list;\n.) Traverse the list twice: first to find the min difference and second to find all pairs with the min difference found  public String displaySmallestDifference(List  numbers) {\nString smallestDifferences = \"\";\n\nCollections.sort(numbers);\n\nInteger smallestDifference = null;\nInteger currentDifference = null;\n\nfor(int i = 0; i\n\n-\nFernando\n on December 11, 2013  Edit  |  Flag\n\n",
    "source":"http://www.careercup.com/question?id=4881711603122176"}
    
---
