/// Mock data for jobs - This file contains all the job-related data

library;

import '../../utils/app_constants.dart';

class JobData {
  /// List of recommended jobs displayed on the home screen
  static const List<Map<String, dynamic>> recommendedJobs = [
    {
      "id": "1",
      "title": "इलेक्ट्रिशियन अप्रेंटिस",
      "company": "VoltX Energy",
      "rating": 4.7,
      "tags": ["Full-Time", "Apprenticeship", "On-site"],
      "salary": "₹1.2L – ₹1.8L P.A.",
      "location": "Nashik, India",
      "time": "3 दिन पहले",
      "logo": "assets/images/company/group.png",
      "review_user_name": "Avery Thompson",
      "review_user_role": "इलेक्ट्रिशियन अप्रेंटिस",
      "description":
          "We are looking for an enthusiastic Electrician Apprentice to join our team...",
      "requirements": [
        "10th or 12th pass",
        "Basic knowledge of electrical systems",
        "Willingness to learn",
        "Good communication skills",
      ],
      "benefits": [
        "On-the-job training",
        "Health insurance",
        "Performance bonuses",
        "Career growth opportunities",
      ],
    },
    {
      "id": "2",
      "title": "फिटर अप्रेंटिस",
      "company": "TechMech Pvt Ltd",
      "rating": 4.3,
      "tags": ["Full-Time", "Apprenticeship"],
      "salary": "₹1.5L – ₹2.0L P.A.",
      "location": "Pune, India",
      "time": "2 दिन पहले",
      "logo": "assets/images/company/group.png",
      "review_user_name": "Jordan Mitchell",
      "review_user_role": "फिटर अप्रेंटिस",
      "description":
          "Join our mechanical team as a Fitter Apprentice and learn from experienced professionals...",
      "requirements": [
        "ITI in Fitter trade",
        "Basic mechanical knowledge",
        "Team player",
        "Safety conscious",
      ],
      "benefits": [
        "Comprehensive training",
        "Competitive salary",
        "Transport allowance",
        "Professional development",
      ],
    },
    {
      "id": "3",
      "title": "वेल्डर अप्रेंटिस",
      "company": "SteelWorks Ltd",
      "rating": 4.6,
      "tags": ["Full-Time", "Training"],
      "salary": "₹1.0L – ₹1.5L P.A.",
      "location": "Mumbai, India",
      "time": "1 दिन पहले",
      "logo": "assets/images/company/group.png",
      "review_user_name": "Kim Shine",
      "review_user_role": "वेल्डर अप्रेंटिस",
      "description":
          "Learn the art of welding with our expert team in a safe and professional environment...",
      "requirements": [
        "10th pass minimum",
        "Interest in welding",
        "Physical fitness",
        "Attention to detail",
      ],
      "benefits": [
        "Certified training program",
        "Safety equipment provided",
        "Overtime opportunities",
        "Skill certification",
      ],
    },
  ];

  /// List of saved jobs (for demonstration purposes)
  static const List<Map<String, dynamic>> savedJobs = [
    {
      "id": "4",
      "title": "मैकेनिक अप्रेंटिस",
      "company": "AutoCare Solutions",
      "rating": 4.5,
      "tags": ["Full-Time", "Training"],
      "salary": "₹1.3L – ₹1.7L P.A.",
      "location": "Delhi, India",
      "time": "5 दिन पहले",
      "logo": "assets/images/company/group.png",
      "review_user_name": "Alex Chen",
      "review_user_role": "मैकेनिक अप्रेंटिस",
    },
  ];

  /// List of applied jobs (for demonstration purposes)
  static const List<Map<String, dynamic>> appliedJobs = [
    {
      "id": "5",
      "title": "प्लंबर अप्रेंटिस",
      "company": "WaterWorks Ltd",
      "rating": 4.2,
      "tags": ["Full-Time", "Apprenticeship"],
      "salary": "₹1.1L – ₹1.6L P.A.",
      "location": "Bangalore, India",
      "time": "1 सप्ताह पहले",
      "logo": "assets/images/company/group.png",
      "status": "Under Review",
    },
  ];

  /// Filter options for job search
  static List<String> get filterOptions => AppConstants.jobFilterOptions;

  /// Job categories for filtering
  static List<String> get jobCategories => AppConstants.jobCategories;

  /// Experience levels
  static List<String> get experienceLevels => AppConstants.experienceLevels;

  /// Salary ranges
  static const List<String> salaryRanges = [
    "Below ₹1L",
    "₹1L - ₹2L",
    "₹2L - ₹3L",
    "₹3L - ₹5L",
    "Above ₹5L",
  ];

  /// Company data
  static const Map<String, Map<String, dynamic>> companies = {
    "VoltX Energy": {
      "name": "VoltX Energy",
      "tagline": "Powering the Future with Sustainable Energy",
      "about":
          "VoltX Energy is a leading renewable energy company committed to providing sustainable power solutions. We specialize in solar, wind, and hydroelectric power generation, helping communities transition to clean energy sources. Our mission is to create a sustainable future while providing reliable and affordable energy solutions.",
      "website": "www.voltxenergy.com",
      "headquarters": "Nashik, Maharashtra, India",
      "founded": "15 March 2010",
      "size": "1500+",
      "revenue": "₹500 Crores",
      "industry": "Renewable Energy",
      "specialties": [
        "Solar Power",
        "Wind Energy",
        "Hydroelectric",
        "Energy Storage",
      ],
      "certifications": ["ISO 9001:2015", "ISO 14001:2015", "OHSAS 18001:2007"],
      "awards": [
        "Best Renewable Energy Company 2023",
        "Green Innovation Award 2022",
      ],
    },
    "TechMech Pvt Ltd": {
      "name": "TechMech Pvt Ltd",
      "tagline": "Innovation in Mechanical Engineering",
      "about":
          "TechMech Pvt Ltd is a premier mechanical engineering company that designs and manufactures precision components for various industries. We focus on innovation, quality, and customer satisfaction, providing cutting-edge solutions for automotive, aerospace, and industrial sectors.",
      "website": "www.techmech.com",
      "headquarters": "Pune, Maharashtra, India",
      "founded": "22 August 2008",
      "size": "800+",
      "revenue": "₹200 Crores",
      "industry": "Mechanical Engineering",
      "specialties": [
        "Precision Engineering",
        "Automotive Components",
        "Aerospace Parts",
        "Industrial Machinery",
      ],
      "certifications": ["ISO 9001:2015", "AS9100D", "IATF 16949:2016"],
      "awards": [
        "Excellence in Manufacturing 2023",
        "Quality Leadership Award 2022",
      ],
    },
    "SteelWorks Ltd": {
      "name": "SteelWorks Ltd",
      "tagline": "Strength in Steel, Excellence in Service",
      "about":
          "SteelWorks Ltd is a leading steel manufacturing company that produces high-quality steel products for construction, automotive, and industrial applications. We are committed to sustainable manufacturing practices and maintaining the highest standards of quality and safety.",
      "website": "www.steelworks.com",
      "headquarters": "Mumbai, Maharashtra, India",
      "founded": "10 December 2005",
      "size": "2000+",
      "revenue": "₹800 Crores",
      "industry": "Steel Manufacturing",
      "specialties": [
        "Steel Production",
        "Construction Steel",
        "Automotive Steel",
        "Industrial Steel",
      ],
      "certifications": ["ISO 9001:2015", "ISO 14001:2015", "OHSAS 18001:2007"],
      "awards": [
        "Steel Excellence Award 2023",
        "Environmental Leadership 2022",
      ],
    },
    "AutoCare Solutions": {
      "name": "AutoCare Solutions",
      "tagline": "Your Vehicle, Our Priority",
      "about":
          "AutoCare Solutions is a comprehensive automotive service and repair company that provides top-quality maintenance and repair services for all types of vehicles. We use advanced diagnostic equipment and employ certified technicians to ensure your vehicle receives the best care possible.",
      "website": "www.autocare.com",
      "headquarters": "Delhi, India",
      "founded": "5 January 2012",
      "size": "300+",
      "revenue": "₹50 Crores",
      "industry": "Automotive Services",
      "specialties": [
        "Vehicle Maintenance",
        "Engine Repair",
        "Electrical Systems",
        "Body Work",
      ],
      "certifications": ["ISO 9001:2015", "Automotive Service Excellence"],
      "awards": [
        "Best Auto Service Provider 2023",
        "Customer Choice Award 2022",
      ],
    },
    "WaterWorks Ltd": {
      "name": "WaterWorks Ltd",
      "tagline": "Pure Water, Pure Life",
      "about":
          "WaterWorks Ltd is a water treatment and plumbing solutions company that provides comprehensive water management services. We specialize in water purification, plumbing installation, and maintenance services for residential, commercial, and industrial clients.",
      "website": "www.waterworks.com",
      "headquarters": "Bangalore, Karnataka, India",
      "founded": "18 June 2009",
      "size": "150+",
      "revenue": "₹25 Crores",
      "industry": "Water Treatment & Plumbing",
      "specialties": [
        "Water Purification",
        "Plumbing Services",
        "Water Treatment",
        "Maintenance",
      ],
      "certifications": ["ISO 9001:2015", "Water Quality Standards"],
      "awards": ["Water Excellence Award 2023", "Service Quality Award 2022"],
    },
  };
}
