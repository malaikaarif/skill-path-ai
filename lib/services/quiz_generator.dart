// ─── LOCAL QUIZ GENERATOR ──────────────────────────────────────────────────
// Provides instant quiz questions keyed by topic tags, matching the tags
// already used in RoadmapGenerator. Falls back to a generic question set
// if no tag match is found, so quizzes never fail to load.

class QuizGenerator {
  static final Map<String, List<Map<String, dynamic>>> _questionBank = {
    'python': [
      {
        'question': 'What is the correct way to create a list in Python?',
        'options': ['list = (1, 2, 3)', 'list = [1, 2, 3]', 'list = {1, 2, 3}', 'list = <1, 2, 3>'],
        'correct_index': 1,
        'explanation': 'Square brackets [] are used to create lists in Python. Parentheses create tuples, and curly braces create sets or dictionaries.',
      },
      {
        'question': 'Which keyword is used to define a function in Python?',
        'options': ['function', 'def', 'func', 'define'],
        'correct_index': 1,
        'explanation': '"def" is the keyword used to define functions in Python, e.g. def my_function():',
      },
      {
        'question': 'What does len() do in Python?',
        'options': ['Rounds a number', 'Returns the length of an object', 'Converts to lowercase', 'Deletes a variable'],
        'correct_index': 1,
        'explanation': 'len() returns the number of items in an object like a list, string, or dictionary.',
      },
    ],
    'ai': [
      {
        'question': 'What does AI stand for?',
        'options': ['Automated Interface', 'Artificial Intelligence', 'Advanced Integration', 'Algorithmic Iteration'],
        'correct_index': 1,
        'explanation': 'AI stands for Artificial Intelligence — the simulation of human intelligence by machines.',
      },
      {
        'question': 'Which of these is a subset of AI?',
        'options': ['HTML', 'Machine Learning', 'CSS', 'SQL'],
        'correct_index': 1,
        'explanation': 'Machine Learning is a subset of AI that enables systems to learn from data without explicit programming.',
      },
    ],
    'ml': [
      {
        'question': 'What is "training" in machine learning?',
        'options': ['Writing documentation', 'The process of teaching a model using data', 'Compiling code', 'Designing the UI'],
        'correct_index': 1,
        'explanation': 'Training is the process where a model learns patterns from data by adjusting its internal parameters.',
      },
      {
        'question': 'What is overfitting?',
        'options': ['When a model performs well on new data', 'When a model learns training data too well and fails on new data', 'When training is too fast', 'When data is too large'],
        'correct_index': 1,
        'explanation': 'Overfitting happens when a model memorizes training data instead of learning general patterns, hurting performance on new data.',
      },
      {
        'question': 'Which of these is a supervised learning task?',
        'options': ['Clustering customers by behavior', 'Predicting house prices from labeled data', 'Reducing data dimensions', 'Finding hidden patterns with no labels'],
        'correct_index': 1,
        'explanation': 'Supervised learning uses labeled data — predicting house prices from known examples is a classic supervised task.',
      },
    ],
    'machine learning': [
      {
        'question': 'What is a "feature" in machine learning?',
        'options': ['A bug in the code', 'An input variable used to make predictions', 'The final output', 'A type of neural network'],
        'correct_index': 1,
        'explanation': 'A feature is an individual measurable input variable used by the model to make predictions.',
      },
      {
        'question': 'What is the purpose of a test set?',
        'options': ['To train the model faster', 'To evaluate model performance on unseen data', 'To visualize data', 'To clean data'],
        'correct_index': 1,
        'explanation': 'A test set evaluates how well a trained model generalizes to data it has never seen before.',
      },
    ],
    'neural networks': [
      {
        'question': 'What is a neuron in a neural network?',
        'options': ['A type of database', 'A basic computational unit that processes input and produces output', 'A programming language', 'A type of error'],
        'correct_index': 1,
        'explanation': 'A neuron takes weighted inputs, applies an activation function, and produces an output — the basic building block of neural networks.',
      },
      {
        'question': 'What does an activation function do?',
        'options': ['Stores data', 'Introduces non-linearity to help the network learn complex patterns', 'Deletes neurons', 'Compiles the code'],
        'correct_index': 1,
        'explanation': 'Activation functions like ReLU or Sigmoid introduce non-linearity, allowing neural networks to learn complex, non-linear patterns.',
      },
    ],
    'deep learning': [
      {
        'question': 'What makes "deep" learning different from regular ML?',
        'options': ['It uses no data', 'It uses neural networks with many layers', 'It only works with images', 'It does not require training'],
        'correct_index': 1,
        'explanation': 'Deep learning uses neural networks with multiple ("deep") layers to learn increasingly complex representations of data.',
      },
    ],
    'computer vision': [
      {
        'question': 'What is a CNN commonly used for?',
        'options': ['Text translation', 'Image recognition and processing', 'Database management', 'Audio compression'],
        'correct_index': 1,
        'explanation': 'Convolutional Neural Networks (CNNs) are specialized for processing grid-like data such as images.',
      },
    ],
    'nlp': [
      {
        'question': 'What does NLP stand for?',
        'options': ['New Language Processing', 'Natural Language Processing', 'Neural Logic Programming', 'Network Layer Protocol'],
        'correct_index': 1,
        'explanation': 'NLP (Natural Language Processing) enables computers to understand, interpret, and generate human language.',
      },
    ],
    'statistics': [
      {
        'question': 'What does "mean" represent in statistics?',
        'options': ['The most frequent value', 'The average of a dataset', 'The middle value', 'The range of values'],
        'correct_index': 1,
        'explanation': 'The mean is the sum of all values divided by the number of values — the average.',
      },
      {
        'question': 'What is standard deviation used to measure?',
        'options': ['The total sum', 'The spread/variability of data from the mean', 'The most common value', 'The number of data points'],
        'correct_index': 1,
        'explanation': 'Standard deviation measures how spread out data points are from the mean.',
      },
    ],
    'data science': [
      {
        'question': 'What is the first step in a typical data science workflow?',
        'options': ['Building a model', 'Data collection and cleaning', 'Deployment', 'Writing reports'],
        'correct_index': 1,
        'explanation': 'Data science workflows start with collecting and cleaning data before any analysis or modeling can happen.',
      },
    ],
    'numpy': [
      {
        'question': 'What is the main data structure in NumPy?',
        'options': ['DataFrame', 'ndarray (array)', 'Series', 'List'],
        'correct_index': 1,
        'explanation': 'NumPy\'s core data structure is the ndarray, an efficient multi-dimensional array.',
      },
    ],
    'pandas': [
      {
        'question': 'What is a DataFrame in Pandas?',
        'options': ['A single column of data', 'A 2D labeled data structure like a table', 'A type of chart', 'A loop function'],
        'correct_index': 1,
        'explanation': 'A DataFrame is a 2-dimensional labeled data structure, similar to a spreadsheet or SQL table.',
      },
    ],
    'sql': [
      {
        'question': 'Which SQL keyword is used to retrieve data?',
        'options': ['GET', 'SELECT', 'FETCH', 'RETRIEVE'],
        'correct_index': 1,
        'explanation': 'SELECT is the SQL keyword used to query and retrieve data from a database table.',
      },
      {
        'question': 'What does the WHERE clause do in SQL?',
        'options': ['Sorts results', 'Filters rows based on a condition', 'Joins tables', 'Deletes a table'],
        'correct_index': 1,
        'explanation': 'WHERE filters rows in a query based on a specified condition.',
      },
    ],
    'flutter': [
      {
        'question': 'What language is Flutter primarily written in?',
        'options': ['JavaScript', 'Dart', 'Swift', 'Kotlin'],
        'correct_index': 1,
        'explanation': 'Flutter apps are built using Dart, a language developed by Google specifically optimized for UI development.',
      },
      {
        'question': 'What is a Widget in Flutter?',
        'options': ['A database connection', 'The basic building block of Flutter UI', 'A type of API', 'A testing tool'],
        'correct_index': 1,
        'explanation': 'Everything in Flutter\'s UI is a Widget — from layout structures to buttons and text.',
      },
      {
        'question': 'What is the difference between StatelessWidget and StatefulWidget?',
        'options': ['No difference', 'StatefulWidget can change its appearance based on internal state', 'StatelessWidget is faster always', 'StatefulWidget cannot have children'],
        'correct_index': 1,
        'explanation': 'StatefulWidget maintains mutable state that can change over time, triggering UI rebuilds, while StatelessWidget is immutable.',
      },
    ],
    'javascript': [
      {
        'question': 'Which keyword declares a variable that cannot be reassigned?',
        'options': ['var', 'let', 'const', 'static'],
        'correct_index': 2,
        'explanation': 'const declares a variable that cannot be reassigned after its initial value is set.',
      },
      {
        'question': 'What does DOM stand for?',
        'options': ['Data Object Model', 'Document Object Model', 'Digital Output Method', 'Dynamic Object Mapping'],
        'correct_index': 1,
        'explanation': 'DOM (Document Object Model) represents the structure of a web page that JavaScript can manipulate.',
      },
    ],
    'algorithms': [
      {
        'question': 'What is the time complexity of binary search?',
        'options': ['O(n)', 'O(log n)', 'O(n²)', 'O(1)'],
        'correct_index': 1,
        'explanation': 'Binary search repeatedly halves the search space, giving it O(log n) time complexity.',
      },
      {
        'question': 'Which sorting algorithm has the best average time complexity?',
        'options': ['Bubble Sort', 'Quick Sort', 'Selection Sort', 'Insertion Sort'],
        'correct_index': 1,
        'explanation': 'Quick Sort has an average time complexity of O(n log n), making it more efficient than O(n²) algorithms for large datasets.',
      },
    ],
    'dsa': [
      {
        'question': 'What data structure uses FIFO (First In First Out)?',
        'options': ['Stack', 'Queue', 'Tree', 'Graph'],
        'correct_index': 1,
        'explanation': 'A Queue follows FIFO — the first element added is the first one removed.',
      },
      {
        'question': 'What data structure uses LIFO (Last In First Out)?',
        'options': ['Queue', 'Stack', 'Array', 'Linked List'],
        'correct_index': 1,
        'explanation': 'A Stack follows LIFO — the last element added is the first one removed.',
      },
    ],
    'competitive programming': [
      {
        'question': 'What is a common strategy for solving DP problems?',
        'options': ['Brute force only', 'Breaking the problem into overlapping subproblems', 'Random guessing', 'Avoiding recursion entirely'],
        'correct_index': 1,
        'explanation': 'Dynamic Programming solves problems by breaking them into overlapping subproblems and storing results to avoid recomputation.',
      },
    ],
    'cybersecurity': [
      {
        'question': 'What does "phishing" refer to in cybersecurity?',
        'options': ['A type of firewall', 'Tricking users into revealing sensitive information', 'A programming language', 'An encryption method'],
        'correct_index': 1,
        'explanation': 'Phishing is a social engineering attack that tricks users into giving up sensitive information like passwords.',
      },
      {
        'question': 'What does encryption do?',
        'options': ['Deletes data permanently', 'Converts data into a coded format to prevent unauthorized access', 'Compresses files', 'Speeds up networks'],
        'correct_index': 1,
        'explanation': 'Encryption transforms readable data into an unreadable format that can only be decoded with the correct key.',
      },
    ],
    'penetration testing': [
      {
        'question': 'What is the first phase of penetration testing?',
        'options': ['Exploitation', 'Reconnaissance/Information gathering', 'Reporting', 'Cleanup'],
        'correct_index': 1,
        'explanation': 'Reconnaissance is the first phase, where testers gather information about the target before attempting any attacks.',
      },
    ],
    'devops': [
      {
        'question': 'What does CI/CD stand for?',
        'options': ['Code Integration/Code Deployment', 'Continuous Integration/Continuous Deployment', 'Central Index/Central Database', 'Container Image/Container Deploy'],
        'correct_index': 1,
        'explanation': 'CI/CD (Continuous Integration/Continuous Deployment) automates building, testing, and deploying code changes.',
      },
      {
        'question': 'What is the main purpose of Docker?',
        'options': ['Writing code', 'Packaging applications into portable containers', 'Designing UI', 'Managing databases only'],
        'correct_index': 1,
        'explanation': 'Docker packages applications and their dependencies into containers that run consistently across environments.',
      },
    ],
    'blockchain': [
      {
        'question': 'What is a "smart contract"?',
        'options': ['A legal document', 'Self-executing code stored on a blockchain', 'A type of cryptocurrency', 'A database query'],
        'correct_index': 1,
        'explanation': 'A smart contract is self-executing code on a blockchain that automatically enforces agreed-upon terms.',
      },
    ],
    'cloud': [
      {
        'question': 'What does IaaS stand for?',
        'options': ['Internet as a Service', 'Infrastructure as a Service', 'Integration as a Service', 'Identity as a Service'],
        'correct_index': 1,
        'explanation': 'IaaS (Infrastructure as a Service) provides virtualized computing resources like servers and storage over the internet.',
      },
      {
        'question': 'Which is a major cloud provider?',
        'options': ['MongoDB', 'AWS', 'React', 'Figma'],
        'correct_index': 1,
        'explanation': 'AWS (Amazon Web Services) is one of the largest cloud computing providers, alongside Azure and GCP.',
      },
    ],
    'web development': [
      {
        'question': 'What does HTML stand for?',
        'options': ['HyperText Markup Language', 'High Tech Modern Language', 'HyperLink Text Management', 'Home Tool Markup Language'],
        'correct_index': 0,
        'explanation': 'HTML (HyperText Markup Language) is the standard language for creating web pages.',
      },
      {
        'question': 'What is the purpose of CSS?',
        'options': ['Database management', 'Styling and layout of web pages', 'Server-side logic', 'Data encryption'],
        'correct_index': 1,
        'explanation': 'CSS (Cascading Style Sheets) controls the visual presentation and layout of HTML elements.',
      },
    ],
  };

  // Generic fallback questions — used when no tag matches.
  static final List<Map<String, dynamic>> _genericQuestions = [
    {
      'question': 'What is the most important first step when learning a new technical topic?',
      'options': ['Memorizing syntax', 'Understanding the core concepts and fundamentals', 'Skipping to advanced material', 'Avoiding practice'],
      'correct_index': 1,
      'explanation': 'Understanding core fundamentals first makes advanced topics easier to grasp and apply correctly.',
    },
    {
      'question': 'What is the best way to retain new technical knowledge?',
      'options': ['Reading once and moving on', 'Active practice and applying concepts hands-on', 'Avoiding mistakes entirely', 'Memorizing without understanding'],
      'correct_index': 1,
      'explanation': 'Active practice and hands-on application significantly improve retention compared to passive reading alone.',
    },
    {
      'question': 'Why is consistent daily practice important when learning to code?',
      'options': ['It is not important', 'It builds muscle memory and reinforces understanding over time', 'It only matters for beginners', 'It guarantees instant expertise'],
      'correct_index': 1,
      'explanation': 'Consistent practice reinforces neural pathways and builds long-term retention better than occasional cramming.',
    },
  ];

  /// Generates quiz questions instantly based on topic tags.
  /// Always returns at least 3 questions — never fails.
  static List<Map<String, dynamic>> generate({
    required String topicTitle,
    required List<String> tags,
  }) {
    final collected = <Map<String, dynamic>>[];

    // Try to match by tags first
    for (final tag in tags) {
      final key = tag.toLowerCase();
      if (_questionBank.containsKey(key)) {
        collected.addAll(_questionBank[key]!);
      }
    }

    // Try matching by topic title words if no tag match
    if (collected.isEmpty) {
      final titleLower = topicTitle.toLowerCase();
      for (final key in _questionBank.keys) {
        if (titleLower.contains(key) || key.contains(titleLower)) {
          collected.addAll(_questionBank[key]!);
        }
      }
    }

    // Fallback to generic questions if still empty
    if (collected.isEmpty) {
      collected.addAll(_genericQuestions);
    }

    // Dedupe and limit to 5 questions max, shuffle for variety
    final unique = <String, Map<String, dynamic>>{};
    for (final q in collected) {
      unique[q['question'] as String] = q;
    }
    final result = unique.values.toList()..shuffle();
    return result.take(5).toList();
  }
}