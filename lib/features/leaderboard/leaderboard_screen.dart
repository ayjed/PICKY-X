import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../services/leaderboard_service.dart';

/// Screen displaying Global and Country/National Leaderboards with Top 3 Podiums and live ranks.
class LeaderboardScreen extends StatefulWidget {
  final LeaderboardService leaderboardService;

  const LeaderboardScreen({
    super.key,
    required this.leaderboardService,
  });

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _showEditProfileDialog() {
    final nameController = TextEditingController(text: widget.leaderboardService.playerName);
    String selectedCountry = widget.leaderboardService.playerCountryCode;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.backgroundSurface,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            title: const Text('Edit Leaderboard Profile', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: const TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surfaceCard,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: selectedCountry,
                  dropdownColor: AppColors.surfaceCard,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  decoration: InputDecoration(
                    labelText: 'Country',
                    labelStyle: const TextStyle(color: AppColors.textMuted),
                    filled: true,
                    fillColor: AppColors.surfaceCard,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'NG', child: Text('🇳🇬 Nigeria')),
                    DropdownMenuItem(value: 'US', child: Text('🇺🇸 United States')),
                    DropdownMenuItem(value: 'GB', child: Text('🇬🇧 United Kingdom')),
                    DropdownMenuItem(value: 'GH', child: Text('🇬🇭 Ghana')),
                    DropdownMenuItem(value: 'CA', child: Text('🇨🇦 Canada')),
                    DropdownMenuItem(value: 'IN', child: Text('🇮🇳 India')),
                    DropdownMenuItem(value: 'DE', child: Text('🇩🇪 Germany')),
                    DropdownMenuItem(value: 'JP', child: Text('🇯🇵 Japan')),
                  ],
                  onChanged: (val) {
                    if (val != null) {
                      setDialogState(() => selectedCountry = val);
                    }
                  },
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.leaderboardService.updateProfile(
                    name: nameController.text.trim().isEmpty ? 'Champion' : nameController.text.trim(),
                    countryCode: selectedCountry,
                  );
                  Navigator.of(ctx).pop();
                  setState(() {});
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryPurple),
                child: const Text('Save Profile', style: TextStyle(color: Colors.white)),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.backgroundGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Header & Profile Edit Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    const Text(
                      'Leaderboards',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textPrimary,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.edit_rounded, color: AppColors.accentYellow),
                      onPressed: _showEditProfileDialog,
                      tooltip: 'Edit Profile',
                    ),
                  ],
                ),
              ),

              // Tabs
              TabBar(
                controller: _tabController,
                indicatorColor: AppColors.accentYellow,
                indicatorWeight: 3,
                labelColor: AppColors.accentYellow,
                unselectedLabelColor: AppColors.textMuted,
                labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                tabs: const [
                  Tab(text: '🌍 GLOBAL', icon: Icon(Icons.public_rounded, size: 20)),
                  Tab(text: '🚩 NATIONAL', icon: Icon(Icons.flag_rounded, size: 20)),
                ],
              ),

              // List Views
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLeaderboardList(widget.leaderboardService.getGlobalLeaderboard()),
                    _buildLeaderboardList(widget.leaderboardService.getNationalLeaderboard()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardList(List<LeaderboardPlayer> players) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      itemCount: players.length,
      itemBuilder: (context, index) {
        final player = players[index];
        final isTop3 = player.rank <= 3;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: player.isMe
                ? AppColors.primaryPurple.withOpacity(0.4)
                : AppColors.backgroundSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: player.isMe
                  ? AppColors.accentYellow
                  : isTop3
                      ? AppColors.accentOrange.withOpacity(0.5)
                      : AppColors.surfaceCardBorder,
              width: player.isMe ? 2.0 : 1.0,
            ),
          ),
          child: Row(
            children: [
              // Rank Badge
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: player.rank == 1
                      ? const Color(0xFFFFD700)
                      : player.rank == 2
                          ? const Color(0xFFC0C0C0)
                          : player.rank == 3
                              ? const Color(0xFFCD7F32)
                              : AppColors.surfaceCard,
                ),
                child: Center(
                  child: Text(
                    '${player.rank}',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      fontSize: 14,
                      color: isTop3 ? Colors.black : AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),

              // Flag & Username
              Text(player.countryFlag, style: const TextStyle(fontSize: 20)),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      player.username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: player.isMe ? AppColors.accentYellow : AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Level ${player.maxLevel} • ${player.totalScore} pts',
                      style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                    ),
                  ],
                ),
              ),

              // Total Stars
              Row(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 16)),
                  const SizedBox(width: 4),
                  Text(
                    '${player.totalStars}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: AppColors.accentYellow,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
