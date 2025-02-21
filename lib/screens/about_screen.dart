import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: const [
          TeamMemberCard(
            name: 'Muhammad Hariz Hakim Bin Zakaria',
            matricNo: '2022496432',
            githubUrl: 'https://github.com/Atan0707',
            phone: '+6017-3408550',
          ),
          SizedBox(height: 16),
          TeamMemberCard(
            name: 'Wan Afiq Danial Bin Wan Norzuhairi',
            matricNo: '2022616498',
            githubUrl: 'https://github.com/afiqq03',
            phone: '+6013-2953112',
          ),
          SizedBox(height: 16),
          TeamMemberCard(
            name: 'MUHAMMAD FIRDAUS BIN ALI',
            matricNo: '2023301351',
            githubUrl: 'https://github.com/Dausali23',
            phone: '+6017-2402503',
          ),
        ],
      ),
    );
  }
}

class TeamMemberCard extends StatelessWidget {
  final String name;
  final String matricNo;
  final String githubUrl;
  final String phone;

  const TeamMemberCard({
    super.key,
    required this.name,
    required this.matricNo,
    required this.githubUrl,
    required this.phone,
  });

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Matric No: $matricNo',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.code),
              title: InkWell(
                onTap: () => _launchUrl(githubUrl),
                child: const Text(
                  'GitHub Profile',
                  style: TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              dense: true,
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(phone),
              dense: true,
            ),
          ],
        ),
      ),
    );
  }
}