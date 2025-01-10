import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:instagramzzz/utils/colors.dart';
import 'package:instagramzzz/widgets/listtile_in_setting.dart';
import 'package:instagramzzz/widgets/search_barr.dart';

class settingAndActivity extends StatefulWidget {
  const settingAndActivity({super.key});

  @override
  State<settingAndActivity> createState() => _settingAndActivityState();
}

class _settingAndActivityState extends State<settingAndActivity> {
  // These variables should be dynamically managed (example values here)
  late String accountPrivacy = 'Public'; // public or private
  late int closeFriend = 5;
  late int blockedAccount = 7;
  late int favourites = 4;
  late int muteAccount = 9;
  late String verified = 'Subscribed'; // Subsribed or Unsubscribed

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: mobileBackgroundColor,
        title: const Text(
          'Settings and Activity',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                SearchBarr(
                  hintText: 'Search',
                  textInputType: TextInputType.text,
                  textEditingController: TextEditingController(),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Your Account',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                    Row(
                      children: const [
                        Icon(
                          CupertinoIcons.infinite,
                        ),
                        SizedBox(width: 5),
                        Text(
                          'Meta',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Container(
                  color: Colors.transparent,
                  child: InkWell(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Icon(
                          Icons.person_sharp,
                          size: 30,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: const [
                              Text(
                                'Account Centre',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w300,
                                ),
                              ),
                              Text(
                                'Password, Security, Personal details, ad preferences. ',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w100,
                                ),
                              )
                            ],
                          ),
                        ),
                        IconButton(
                          iconSize: 30,
                          onPressed: () {},
                          icon: const Icon(Icons.arrow_right),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // First Section: Your Account
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text:
                        'Manage your connected experiences and accounts settings across Meta technologies. ',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                  TextSpan(
                    text: 'Learn more.',
                    style: TextStyle(
                      color: Colors.blue,
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const Divider(thickness: 8),

          // Second Section: How you use Instagram
          _buildSectionHeader('How you use Instagram'),
          _buildListTiles([
            {
              'icon': Icons.bookmark,
              'title': 'Saved',
            },
            {
              'icon': Icons.archive_outlined,
              'title': 'Archive',
            },
            {
              'icon': Icons.local_activity,
              'title': 'Your activity',
            },
            {
              'icon': Icons.notifications,
              'title': 'Notifications',
            },
            {
              'icon': Icons.timer,
              'title': 'Time management',
            },
          ]),

          const Divider(thickness: 8),

          // Third Section: Who can see your content
          _buildSectionHeader('Who can see your content'),
          _buildListTiles([
            {
              'icon': Icons.lock,
              'title': 'Account privacy',
              'trailingText': accountPrivacy
            },
            {
              'icon': Icons.favorite,
              'title': 'Close Friend',
              'trailingText': closeFriend.toString()
            },
            {
              'icon': Icons.post_add,
              'title': 'Crossposting',
            },
            {
              'icon': Icons.block,
              'title': 'Blocked',
              'trailingText': blockedAccount.toString()
            },
            {
              'icon': Icons.hide_source,
              'title': 'Hide story and live',
            },
          ]),

          const Divider(thickness: 8),

          // Fourth Section: How others can interact with you
          _buildSectionHeader('How others can interact with you'),
          _buildListTiles([
            {
              'icon': Icons.messenger_outline_rounded,
              'title': 'Message and story replies'
            },
            {
              'icon': Icons.tag_faces_sharp,
              'title': 'Tags and mentions',
            },
            {
              'icon': Icons.comment_rounded,
              'title': 'Comments',
            },
            {
              'icon': Icons.share,
              'title': 'Sharing and reuse',
            },
            {
              'icon': Icons.person_3,
              'title': 'Avatar interaction',
            },
            {
              'icon': Icons.block_flipped,
              'title': 'Restricted',
            },
            {
              'icon': Icons.sort_by_alpha,
              'title': 'Hidden words',
            },
            {
              'icon': Icons.add,
              'title': 'Follow and invite friends',
            },
          ]),

          const Divider(thickness: 8),

          // Fifth section
          _buildSectionHeader('What you can see'),
          _buildListTiles([
            {
              'icon': Icons.star,
              'title': 'Favourites',
              'trailingText': favourites.toString(),
            },
            {
              'icon': Icons.do_not_disturb_alt_outlined,
              'title': 'Muted Accounts',
              'trailingText': muteAccount.toString(),
            },
            {
              'icon': Icons.content_paste,
              'title': 'Suggested content',
            },
            {
              'icon': Icons.favorite_border_outlined,
              'title': 'Like and share counts',
            },
          ]),

          const Divider(thickness: 8),

          // Sixth section
          _buildSectionHeader('Your app and media'),
          _buildListTiles([
            {
              'icon': Icons.device_hub,
              'title': 'Device permissions',
            },
            {
              'icon': Icons.download,
              'title': 'Archiving and downloading',
            },
            {
              'icon': Icons.language,
              'title': 'Language',
            },
            {
              'icon': Icons.data_usage,
              'title': 'Data usage and media quality',
            },
            {
              'icon': Icons.web,
              'title': 'App website permissions',
            },
            {
              'icon': Icons.featured_play_list,
              'title': 'Early access to features',
            },
          ]),

          const Divider(thickness: 8),

          // Seventh section
          _buildSectionHeader('For families'),
          _buildListTiles([
            {
              'icon': Icons.family_restroom,
              'title': 'Family centre',
            }
          ]),

          const Divider(thickness: 8),

          // Eighth section
          _buildSectionHeader('For professionals'),
          _buildListTiles([
            {
              'icon': Icons.table_chart,
              'title': 'Account types and tools',
            },
            {
              'icon': Icons.verified,
              'title': 'Meta Verified',
              'trailingText': verified,
            },
          ]),

          const Divider(thickness: 8),

          // Ninth section
          _buildSectionHeader('Your order and fundraisers'),
          _buildListTiles([
            {
              'icon': Icons.payment,
              'title': 'Orders and payment',
            }
          ]),

          const Divider(thickness: 8),

          // Tenth section
          _buildSectionHeader('More info and support'),
          _buildListTiles([
            {
              'icon': Icons.help,
              'title': 'Help',
            },
            {
              'icon': Icons.privacy_tip,
              'title': 'Privacy centre',
            },
            {
              'icon': Icons.person_2_outlined,
              'title': 'Account status',
            },
            {
              'icon': CupertinoIcons.infinite,
              'title': 'About',
            },
          ]),

          const Divider(thickness: 8),

          // Eleventh section
          ListTile(
            title: Text(
              'Add account',
              style: TextStyle(
                color: Colors.blue,
                fontSize: 20,
              ),
            ),
          ),
          ListTile(
            title: Text(
              'Log out',
              style: TextStyle(
                color: Colors.red,
                fontSize: 20,
              ),
            ),
          ),
          ListTile(
            title: Text(
              'Log out of all accounts',
              style: TextStyle(
                color: Colors.red,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Reusable Widget for Section Header
  Widget _buildSectionHeader(String title, {bool hasMeta = false}) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w300,
            ),
          ),
          if (hasMeta)
            Row(
              children: const [
                Icon(Icons.facebook),
                Text(
                  'Meta',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  // Reusable Widget for Multiple List Tiles
  Widget _buildListTiles(List<Map<String, dynamic>> tilesData) {
    return Column(
      children: tilesData.map((data) {
        return _buildListTile(
          icon: data['icon'],
          title: data['title'],
          subtitle: data['subtitle'],
          trailingText: data['trailingText'],
          onTap: () => print('${data['title']} tapped'),
        );
      }).toList(),
    );
  }

  // Reusable Widget for a Single List Tile
  Widget _buildListTile({
    required IconData icon,
    required String title,
    String? subtitle,
    String? trailingText,
    VoidCallback? onTap,
  }) {
    return ListtileInSetting(
      icons: Icon(
        icon,
        size: 30,
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.normal,
        ),
      ),
      text: trailingText != null
          ? Text(
              trailingText,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w300,
              ),
            )
          : null,
    );
  }
}
