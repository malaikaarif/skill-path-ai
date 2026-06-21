// ─── LOCAL ROADMAP GENERATOR ──────────────────────────────────────────────
// Generates personalized learning roadmaps instantly, without any API call.
// Roadmaps are hand-curated per goal + adjusted for level and pace.

class RoadmapGenerator {
  // Base roadmaps per goal — each topic has a base duration in days.
  // Duration is later scaled based on hours/day selected.
  static final Map<String, List<Map<String, dynamic>>> _roadmaps = {
    'AI / ML Engineer': [
      {
        'title': 'Python Fundamentals',
        'description': 'Master Python syntax, data structures, and core programming concepts',
        'difficulty': 'beginner',
        'tags': ['python'],
        'base_days': 5,
      },
      {
        'title': 'Mathematics for ML',
        'description': 'Learn linear algebra, calculus, and probability essential for machine learning',
        'difficulty': 'beginner',
        'tags': ['statistics', 'ml'],
        'base_days': 7,
      },
      {
        'title': 'NumPy & Pandas',
        'description': 'Master data manipulation and numerical computing libraries',
        'difficulty': 'beginner',
        'tags': ['numpy', 'pandas'],
        'base_days': 4,
      },
      {
        'title': 'Machine Learning Fundamentals',
        'description': 'Understand supervised, unsupervised learning, and core ML algorithms',
        'difficulty': 'intermediate',
        'tags': ['machine learning', 'ml'],
        'base_days': 10,
      },
      {
        'title': 'Neural Networks & Deep Learning',
        'description': 'Learn how neural networks work and build your first deep learning models',
        'difficulty': 'intermediate',
        'tags': ['neural networks', 'deep learning'],
        'base_days': 10,
      },
      {
        'title': 'Computer Vision Basics',
        'description': 'Explore image processing and convolutional neural networks',
        'difficulty': 'intermediate',
        'tags': ['computer vision'],
        'base_days': 8,
      },
      {
        'title': 'NLP & Transformers',
        'description': 'Learn natural language processing and modern transformer architectures',
        'difficulty': 'advanced',
        'tags': ['nlp'],
        'base_days': 8,
      },
      {
        'title': 'Deploying ML Models',
        'description': 'Learn to deploy models using FastAPI, Docker, and cloud platforms',
        'difficulty': 'advanced',
        'tags': ['cloud', 'ai'],
        'base_days': 6,
      },
    ],
    'Full-Stack Developer': [
      {
        'title': 'HTML & CSS Fundamentals',
        'description': 'Learn the building blocks of web pages and modern styling',
        'difficulty': 'beginner',
        'tags': ['web development'],
        'base_days': 5,
      },
      {
        'title': 'JavaScript Essentials',
        'description': 'Master JavaScript syntax, DOM manipulation, and ES6+ features',
        'difficulty': 'beginner',
        'tags': ['javascript'],
        'base_days': 7,
      },
      {
        'title': 'Frontend Framework (React)',
        'description': 'Build interactive UIs with components, hooks, and state management',
        'difficulty': 'intermediate',
        'tags': ['javascript', 'web development'],
        'base_days': 10,
      },
      {
        'title': 'Backend Fundamentals',
        'description': 'Learn server-side programming, REST APIs, and Node.js/Express',
        'difficulty': 'intermediate',
        'tags': ['web development'],
        'base_days': 8,
      },
      {
        'title': 'Databases & SQL',
        'description': 'Master relational databases, queries, and data modeling',
        'difficulty': 'intermediate',
        'tags': ['sql'],
        'base_days': 6,
      },
      {
        'title': 'Authentication & Security',
        'description': 'Implement secure login systems, JWT, and best security practices',
        'difficulty': 'intermediate',
        'tags': ['cybersecurity', 'web development'],
        'base_days': 5,
      },
      {
        'title': 'Full-Stack Project',
        'description': 'Build and connect a complete frontend + backend application',
        'difficulty': 'advanced',
        'tags': ['web development'],
        'base_days': 8,
      },
      {
        'title': 'Deployment & DevOps Basics',
        'description': 'Deploy your app using CI/CD, Docker, and cloud hosting',
        'difficulty': 'advanced',
        'tags': ['devops', 'cloud'],
        'base_days': 5,
      },
    ],
    'Data Scientist': [
      {
        'title': 'Python for Data Science',
        'description': 'Learn Python fundamentals tailored for data analysis',
        'difficulty': 'beginner',
        'tags': ['python', 'data science'],
        'base_days': 5,
      },
      {
        'title': 'Statistics & Probability',
        'description': 'Build a strong foundation in statistical concepts for data analysis',
        'difficulty': 'beginner',
        'tags': ['statistics'],
        'base_days': 7,
      },
      {
        'title': 'Data Wrangling with Pandas',
        'description': 'Clean, transform, and manipulate real-world datasets',
        'difficulty': 'beginner',
        'tags': ['pandas', 'numpy'],
        'base_days': 6,
      },
      {
        'title': 'Data Visualization',
        'description': 'Create insightful charts and dashboards with Matplotlib and Seaborn',
        'difficulty': 'intermediate',
        'tags': ['data science'],
        'base_days': 5,
      },
      {
        'title': 'SQL for Data Analysis',
        'description': 'Query and analyze data stored in relational databases',
        'difficulty': 'intermediate',
        'tags': ['sql'],
        'base_days': 5,
      },
      {
        'title': 'Machine Learning for Data Science',
        'description': 'Apply ML models to extract insights and make predictions',
        'difficulty': 'intermediate',
        'tags': ['machine learning', 'ml'],
        'base_days': 9,
      },
      {
        'title': 'Storytelling with Data',
        'description': 'Learn to communicate insights effectively to stakeholders',
        'difficulty': 'advanced',
        'tags': ['data science'],
        'base_days': 4,
      },
      {
        'title': 'End-to-End Data Project',
        'description': 'Complete a full data science project from raw data to insights',
        'difficulty': 'advanced',
        'tags': ['data science', 'ml'],
        'base_days': 8,
      },
    ],
    'Mobile Developer': [
      {
        'title': 'Introduction to Mobile Development',
        'description': 'Understand mobile app development concepts and platforms',
        'difficulty': 'beginner',
        'tags': ['flutter'],
        'base_days': 3,
      },
      {
        'title': 'Programming Languages for Mobile Apps',
        'description': 'Learn Dart/Kotlin fundamentals for mobile development',
        'difficulty': 'beginner',
        'tags': ['flutter'],
        'base_days': 6,
      },
      {
        'title': 'UI Design & Widgets',
        'description': 'Build responsive layouts and reusable UI components',
        'difficulty': 'beginner',
        'tags': ['flutter'],
        'base_days': 6,
      },
      {
        'title': 'State Management',
        'description': 'Manage app state using Provider, Riverpod, or similar patterns',
        'difficulty': 'intermediate',
        'tags': ['flutter'],
        'base_days': 6,
      },
      {
        'title': 'APIs & Networking',
        'description': 'Connect your app to backend services and handle data fetching',
        'difficulty': 'intermediate',
        'tags': ['flutter', 'web development'],
        'base_days': 5,
      },
      {
        'title': 'Local Storage & Databases',
        'description': 'Persist data locally using SQLite, Hive, or Firebase',
        'difficulty': 'intermediate',
        'tags': ['flutter'],
        'base_days': 5,
      },
      {
        'title': 'Native Device Features',
        'description': 'Integrate camera, location, notifications, and sensors',
        'difficulty': 'advanced',
        'tags': ['flutter'],
        'base_days': 5,
      },
      {
        'title': 'Publishing Your App',
        'description': 'Prepare and publish your app to the App Store and Play Store',
        'difficulty': 'advanced',
        'tags': ['flutter'],
        'base_days': 4,
      },
    ],
    'Cloud Engineer': [
      {
        'title': 'Cloud Computing Fundamentals',
        'description': 'Understand core cloud concepts, IaaS, PaaS, and SaaS',
        'difficulty': 'beginner',
        'tags': ['cloud'],
        'base_days': 5,
      },
      {
        'title': 'Linux & Command Line',
        'description': 'Master essential Linux commands and system administration',
        'difficulty': 'beginner',
        'tags': ['cloud', 'devops'],
        'base_days': 6,
      },
      {
        'title': 'Networking Basics',
        'description': 'Learn networking fundamentals essential for cloud architecture',
        'difficulty': 'beginner',
        'tags': ['cloud'],
        'base_days': 6,
      },
      {
        'title': 'AWS/Azure/GCP Fundamentals',
        'description': 'Get hands-on with core services of a major cloud provider',
        'difficulty': 'intermediate',
        'tags': ['cloud'],
        'base_days': 10,
      },
      {
        'title': 'Infrastructure as Code',
        'description': 'Automate infrastructure using Terraform or CloudFormation',
        'difficulty': 'intermediate',
        'tags': ['cloud', 'devops'],
        'base_days': 7,
      },
      {
        'title': 'Containers & Kubernetes',
        'description': 'Learn Docker and container orchestration with Kubernetes',
        'difficulty': 'intermediate',
        'tags': ['devops', 'cloud'],
        'base_days': 8,
      },
      {
        'title': 'CI/CD Pipelines',
        'description': 'Build automated deployment pipelines for cloud applications',
        'difficulty': 'advanced',
        'tags': ['devops'],
        'base_days': 6,
      },
      {
        'title': 'Cloud Security & Monitoring',
        'description': 'Secure cloud infrastructure and set up monitoring systems',
        'difficulty': 'advanced',
        'tags': ['cloud', 'cybersecurity'],
        'base_days': 6,
      },
    ],
    'Cybersecurity Expert': [
      {
        'title': 'Cybersecurity Fundamentals',
        'description': 'Understand core security principles, threats, and terminology',
        'difficulty': 'beginner',
        'tags': ['cybersecurity'],
        'base_days': 5,
      },
      {
        'title': 'Networking for Security',
        'description': 'Learn networking concepts essential for security analysis',
        'difficulty': 'beginner',
        'tags': ['cybersecurity'],
        'base_days': 6,
      },
      {
        'title': 'Linux for Security Professionals',
        'description': 'Master Linux systems used in security tooling and analysis',
        'difficulty': 'beginner',
        'tags': ['cybersecurity'],
        'base_days': 6,
      },
      {
        'title': 'Cryptography Basics',
        'description': 'Understand encryption, hashing, and secure communication',
        'difficulty': 'intermediate',
        'tags': ['cybersecurity'],
        'base_days': 6,
      },
      {
        'title': 'Web Application Security',
        'description': 'Learn common vulnerabilities like XSS, SQL injection, and CSRF',
        'difficulty': 'intermediate',
        'tags': ['cybersecurity', 'penetration testing'],
        'base_days': 8,
      },
      {
        'title': 'Ethical Hacking Basics',
        'description': 'Introduction to penetration testing tools and methodology',
        'difficulty': 'intermediate',
        'tags': ['penetration testing'],
        'base_days': 8,
      },
      {
        'title': 'Security Tools & TryHackMe Labs',
        'description': 'Get hands-on with industry-standard security tools',
        'difficulty': 'advanced',
        'tags': ['penetration testing', 'cybersecurity'],
        'base_days': 8,
      },
      {
        'title': 'Incident Response & Reporting',
        'description': 'Learn how to respond to security incidents and write reports',
        'difficulty': 'advanced',
        'tags': ['cybersecurity'],
        'base_days': 5,
      },
    ],
    'DSA & Competitive Programming': [
      {
        'title': 'Programming Language Basics',
        'description': 'Get comfortable with C++/Python syntax for competitive programming',
        'difficulty': 'beginner',
        'tags': ['dsa'],
        'base_days': 4,
      },
      {
        'title': 'Arrays & Strings',
        'description': 'Master fundamental data structures and common patterns',
        'difficulty': 'beginner',
        'tags': ['dsa', 'algorithms'],
        'base_days': 6,
      },
      {
        'title': 'Linked Lists, Stacks & Queues',
        'description': 'Learn linear data structures and their applications',
        'difficulty': 'beginner',
        'tags': ['dsa'],
        'base_days': 6,
      },
      {
        'title': 'Recursion & Backtracking',
        'description': 'Solve problems using recursive thinking and backtracking techniques',
        'difficulty': 'intermediate',
        'tags': ['dsa', 'algorithms'],
        'base_days': 7,
      },
      {
        'title': 'Trees & Graphs',
        'description': 'Master tree traversals, BST, and graph algorithms like BFS/DFS',
        'difficulty': 'intermediate',
        'tags': ['dsa', 'algorithms'],
        'base_days': 9,
      },
      {
        'title': 'Dynamic Programming',
        'description': 'Learn to solve optimization problems using DP patterns',
        'difficulty': 'advanced',
        'tags': ['dsa', 'algorithms'],
        'base_days': 9,
      },
      {
        'title': 'Greedy Algorithms & Sorting',
        'description': 'Master greedy techniques and advanced sorting algorithms',
        'difficulty': 'advanced',
        'tags': ['algorithms'],
        'base_days': 6,
      },
      {
        'title': 'Competitive Programming Practice',
        'description': 'Apply your skills on Codeforces and LeetCode contests',
        'difficulty': 'advanced',
        'tags': ['competitive programming'],
        'base_days': 8,
      },
    ],
    'Penetration Tester': [
      {
        'title': 'Networking & Security Fundamentals',
        'description': 'Build a foundation in networking concepts for pentesting',
        'difficulty': 'beginner',
        'tags': ['cybersecurity'],
        'base_days': 6,
      },
      {
        'title': 'Linux & Scripting Basics',
        'description': 'Master Linux and basic scripting for security automation',
        'difficulty': 'beginner',
        'tags': ['cybersecurity'],
        'base_days': 6,
      },
      {
        'title': 'Reconnaissance Techniques',
        'description': 'Learn information gathering and footprinting methods',
        'difficulty': 'intermediate',
        'tags': ['penetration testing'],
        'base_days': 5,
      },
      {
        'title': 'Vulnerability Scanning',
        'description': 'Identify vulnerabilities using industry-standard scanning tools',
        'difficulty': 'intermediate',
        'tags': ['penetration testing'],
        'base_days': 6,
      },
      {
        'title': 'Web App Penetration Testing',
        'description': 'Test web applications for security flaws hands-on',
        'difficulty': 'intermediate',
        'tags': ['penetration testing', 'cybersecurity'],
        'base_days': 9,
      },
      {
        'title': 'Exploitation Techniques',
        'description': 'Learn how to safely exploit identified vulnerabilities',
        'difficulty': 'advanced',
        'tags': ['penetration testing'],
        'base_days': 8,
      },
      {
        'title': 'HackTheBox / TryHackMe Practice',
        'description': 'Apply your skills on real-world practice labs',
        'difficulty': 'advanced',
        'tags': ['penetration testing'],
        'base_days': 8,
      },
      {
        'title': 'Reporting & Certifications Path',
        'description': 'Learn professional reporting and certification roadmap (OSCP, CEH)',
        'difficulty': 'advanced',
        'tags': ['cybersecurity'],
        'base_days': 4,
      },
    ],
    'DevOps Engineer': [
      {
        'title': 'Linux & Shell Scripting',
        'description': 'Master Linux administration and automation scripting',
        'difficulty': 'beginner',
        'tags': ['devops'],
        'base_days': 6,
      },
      {
        'title': 'Version Control with Git',
        'description': 'Master Git workflows for collaborative development',
        'difficulty': 'beginner',
        'tags': ['devops'],
        'base_days': 4,
      },
      {
        'title': 'Networking Fundamentals',
        'description': 'Understand networking concepts essential for DevOps',
        'difficulty': 'beginner',
        'tags': ['devops', 'cloud'],
        'base_days': 5,
      },
      {
        'title': 'Containers with Docker',
        'description': 'Learn containerization and Docker fundamentals',
        'difficulty': 'intermediate',
        'tags': ['devops'],
        'base_days': 7,
      },
      {
        'title': 'CI/CD Pipelines',
        'description': 'Build automated build, test, and deployment pipelines',
        'difficulty': 'intermediate',
        'tags': ['devops'],
        'base_days': 8,
      },
      {
        'title': 'Kubernetes Orchestration',
        'description': 'Deploy and manage containerized applications at scale',
        'difficulty': 'intermediate',
        'tags': ['devops'],
        'base_days': 9,
      },
      {
        'title': 'Infrastructure as Code',
        'description': 'Automate infrastructure provisioning with Terraform',
        'difficulty': 'advanced',
        'tags': ['devops', 'cloud'],
        'base_days': 7,
      },
      {
        'title': 'Monitoring & Logging',
        'description': 'Set up observability with Prometheus, Grafana, and ELK',
        'difficulty': 'advanced',
        'tags': ['devops'],
        'base_days': 6,
      },
    ],
    'Blockchain Developer': [
      {
        'title': 'Blockchain Fundamentals',
        'description': 'Understand how blockchain, consensus, and decentralization work',
        'difficulty': 'beginner',
        'tags': ['blockchain'],
        'base_days': 5,
      },
      {
        'title': 'JavaScript & Web3 Basics',
        'description': 'Build the programming foundation needed for Web3 development',
        'difficulty': 'beginner',
        'tags': ['javascript', 'blockchain'],
        'base_days': 6,
      },
      {
        'title': 'Solidity Fundamentals',
        'description': 'Learn Solidity syntax and smart contract basics',
        'difficulty': 'intermediate',
        'tags': ['blockchain'],
        'base_days': 9,
      },
      {
        'title': 'Smart Contract Development',
        'description': 'Build, test, and deploy smart contracts on Ethereum',
        'difficulty': 'intermediate',
        'tags': ['blockchain'],
        'base_days': 9,
      },
      {
        'title': 'Web3.js & Ethers.js',
        'description': 'Connect frontend applications to blockchain smart contracts',
        'difficulty': 'intermediate',
        'tags': ['blockchain', 'javascript'],
        'base_days': 6,
      },
      {
        'title': 'DeFi Concepts',
        'description': 'Understand decentralized finance protocols and mechanisms',
        'difficulty': 'advanced',
        'tags': ['blockchain'],
        'base_days': 7,
      },
      {
        'title': 'Smart Contract Security',
        'description': 'Learn common vulnerabilities and security best practices',
        'difficulty': 'advanced',
        'tags': ['blockchain', 'cybersecurity'],
        'base_days': 6,
      },
      {
        'title': 'Building a Full dApp',
        'description': 'Build and deploy a complete decentralized application',
        'difficulty': 'advanced',
        'tags': ['blockchain'],
        'base_days': 8,
      },
    ],
  };

  /// Generates a roadmap instantly based on goal, level, and hours/day.
  /// No API call required — always works, always fast.
  static List<Map<String, dynamic>> generate({
    required String goal,
    required String level,
    required String hoursPerDay,
  }) {
    final baseTopics = _roadmaps[goal] ?? _roadmaps['Full-Stack Developer']!;

    // Scale duration based on hours per day selected.
    // Less time per day → more days needed for same topic.
    double scaleFactor = 1.0;
    switch (hoursPerDay) {
      case '0.5 hr':
        scaleFactor = 1.8;
        break;
      case '1 hr':
        scaleFactor = 1.3;
        break;
      case '2 hrs':
        scaleFactor = 1.0;
        break;
      case '3+ hrs':
        scaleFactor = 0.7;
        break;
    }

    // Filter topics based on level — beginners get all topics,
    // intermediate/advanced users skip the most basic ones.
    List<Map<String, dynamic>> selectedTopics;
    if (level == 'Advanced') {
      // Skip first 2 beginner topics, focus on intermediate/advanced
      selectedTopics = baseTopics.skip(2).toList();
    } else if (level == 'Intermediate') {
      // Skip first topic only
      selectedTopics = baseTopics.skip(1).toList();
    } else {
      selectedTopics = baseTopics;
    }

    // Build final roadmap with computed fields
    final roadmap = <Map<String, dynamic>>[];
    for (int i = 0; i < selectedTopics.length; i++) {
      final topic = selectedTopics[i];
      final baseDays = topic['base_days'] as int;
      final scaledDays = (baseDays * scaleFactor).round().clamp(1, 30);

      roadmap.add(Map<String, dynamic>.from({
        'id': 'topic_${i + 1}',
        'title': topic['title'],
        'description': topic['description'],
        'duration_days': scaledDays,
        'difficulty': topic['difficulty'],
        'tags': List<String>.from(topic['tags'] as List),
        'score': 1.0,
        'order': i + 1,
        'completed': false,
      }));
    }

    return roadmap;
  }
}