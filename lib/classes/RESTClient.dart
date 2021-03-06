import 'package:grad_project/classes/Comment.dart';
import 'package:grad_project/classes/Filter.dart';
import 'package:grad_project/classes/PostVote.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'Post.dart';
import 'User.dart';
import 'Topic.dart';
import 'College.dart';
import 'Department.dart';

class RESTClient {
  static const SERVER_URL = 'http://10.0.2.2:5000/';
  static User currentUser;
  static List<College> colleges;
  static List<Post> timelinePosts;
  
  
  static void login(User user) async {
    /* var response = await http.post(
      Uri.encodeFull(SERVER_URL + 'api/login'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json'
      },
      body: jsonEncode(<String, String>{
        'email': user.email,
        'password': user.password,
      }),
    );

    print(response.body);

    if (response.statusCode == 200) {
      User user = User.fromJson(json.decode(response.body));
      currentUser =  user;
    } else if (response.statusCode == 401) {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      print('Failed to login');
      throw Exception('Failed to login');
    }

    return null; */

    
    

    List<Filter> queryFilters = List();
    queryFilters.add(Filter(name: "email", operator: "eq", value: user.email));
    queryFilters.add(Filter(name: "password", operator: "eq", value: user.password));    

    Map<String, dynamic> queryFiltersMap = Map();
    queryFiltersMap['filters'] = queryFilters;

    String query = '?q=' + jsonEncode(queryFiltersMap);

    var response = await http.get(Uri.encodeFull(SERVER_URL + 'api/users' + query));
    print("Query: "+ query);
    print("response   " + response.body);

    if (response.statusCode == 200) {
      List<dynamic> objects = jsonDecode(response.body)['objects'];
      List<User> users =
      objects.map((dynamic item) => User.fromJson(item)).toList();

      currentUser = users[0];
      //return colleges;
    } else if (response.statusCode == 401) {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      print('Failed to login');
      throw Exception('Failed to login');
    }
  }

  static void register(User user) async {
    final response = await http.post(
      Uri.encodeFull(SERVER_URL + 'api/users'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Accept': 'application/json'
      },
      body: jsonEncode(user),
    );

    Map jsonResponse = json.decode(response.body);
    print(jsonResponse);
    if (response.statusCode == 201)
      currentUser =  User.fromJson(jsonResponse);
    else if (response.statusCode == 400) {
      String errorMessage = jsonResponse['message'];
      print('Failed to register user: $errorMessage');
      throw Exception('Failed to register user: $errorMessage');
    }

    return null;
  }

  static Future<List<Topic>> getAllTopics() async {
    var response = await http.get(Uri.encodeFull(SERVER_URL + 'api/topics'));

    print("response   " + response.body);

    if (response.statusCode == 200) {
      List<dynamic> objects = jsonDecode(response.body)['objects'];
      List<Topic> topics =
          objects.map((dynamic item) => Topic.fromJson(item)).toList();

      return topics;
    } else if (response.statusCode == 401) {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      print('Failed to login');
      throw Exception('Failed to login');
    }

    return null;
  }

  static Future<List<College>> getAllColleges() async {
    var response = await http.get(Uri.encodeFull(SERVER_URL + 'api/colleges'));

    print("response   " + response.body);

    if (response.statusCode == 200) {
      List<dynamic> objects = jsonDecode(response.body)['objects'];
      List<College> colleges =
          objects.map((dynamic item) => College.fromJson(item)).toList();

      RESTClient.colleges = colleges;
      return colleges;
    } else if (response.statusCode == 401) {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      print('Failed to login');
      throw Exception('Failed to login');
    }

    return null;
  }

  static Future<Topic> addTopic(Topic topic) async {
    final response = await http.post(
      Uri.encodeFull(SERVER_URL + 'api/topics'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(topic),
    );

    Map jsonResponse = json.decode(response.body);
    print(jsonResponse);

    return null;
  }

  static Future<Department> addDepartment(Department department) async {
    final response = await http.post(
      Uri.encodeFull(SERVER_URL + 'api/departments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(department),
    );
    Map jsonResponse = json.decode(response.body);
    print(jsonResponse);

    return null;
  }

  static Future<College> addCollege(College college) async {
    final response = await http.post(
      Uri.encodeFull(SERVER_URL + 'api/colleges'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(college),
    );

    Map jsonResponse = json.decode(response.body);
    print(jsonResponse);

    return null;
  }

  static Future<Post> addPost(Post post) async {
    final response = await http.post(
      Uri.encodeFull(SERVER_URL + 'api/posts'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(post),
    );

    Map jsonResponse = json.decode(response.body);
    print(jsonResponse);

    return null;
  }

  static Future<Comment> addComment(Comment comment) async {
    final response = await http.post(
      Uri.encodeFull(SERVER_URL + 'api/comments'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(comment),
    );

    Map jsonResponse = json.decode(response.body);
    print(jsonResponse);

    return null;
  }

  static Future<PostVote> addPostVote(PostVote postVote) async {
    final response = await http.post(
      Uri.encodeFull(SERVER_URL + 'api/posts_votes'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(postVote),
    );

    Map jsonResponse = json.decode(response.body);
    print(jsonResponse);

    return null;
  }

  static void getUserTimeline(Duration duration) async {
    List<Filter> interestsFilters = List();
    for(int i = 0; i < currentUser.interests.length; i++) {
      Topic t = currentUser.interests[i];
      Filter f = Filter(name: "topics", operator: "any", value: Filter(name: "id", operator: "eq", value: t.id));
      interestsFilters.add(f);
    }
    DateTime startDate = DateTime.now().subtract(duration);
    Map<String, dynamic> interestsFiltersMap = Map();
    interestsFiltersMap['or'] = interestsFilters;

    List<dynamic> queryFilters = List();
    queryFilters.add(interestsFiltersMap);
    queryFilters.add(Filter(name: "timestamp", operator: "gte", value: startDate.toIso8601String()));
    
    Map<String, dynamic> queryFiltersMap = Map();
    queryFiltersMap['filters'] = queryFilters;

    String query = '?q=' + jsonEncode(queryFiltersMap);

    var response = await http.get(Uri.encodeFull(SERVER_URL + 'api/posts' + query));
    print("Query: "+ query);
    print("response   " + response.body);

    if (response.statusCode == 200) {
      List<dynamic> objects = jsonDecode(response.body)['objects'];
      List<Post> posts =
      objects.map((dynamic item) => Post.fromJson(item)).toList();

      print("Length: " + posts.length.toString());
      
      timelinePosts = posts;
    } else if (response.statusCode == 401) {
      // If the server did not return a 200 OK response,
      // then throw an exception.
      print('Failed to get posts');
      throw Exception('Failed to get posts');
    }

    return null;
  }

  //localhost:5000/api/posts?q={"filters":[{"or":[{"name":"id","op":"gt","val":0},{"name":"author_id","op":"gt","val":0}]}]}
}
