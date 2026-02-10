import 'package:auto_flow/constants/app_paddings.dart';
import 'package:auto_flow/constants/app_textstyles.dart';
import 'package:auto_flow/features/home/widgets/profile_Header.dart';
import 'package:auto_flow/features/home/widgets/section_card.dart';
import 'package:auto_flow/features/home/widgets/tool_tiles.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Text(
          "Home",
          style: AppTextStyles.midHeader(
            context,
          ).copyWith(color: colorScheme.primary),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.workspace_premium_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: Padding(
        padding: AppPaddings.all16,
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ProfileHeader(colorScheme: colorScheme),
              const SizedBox(height: 24),
              SectionCard(
                title: "Upload Limit",
                icon: Icons.warning,
                child: Text(
                  "Upload limit for the day: 1/3 left",
                  style: AppTextStyles.smallHeader(
                    context,
                  ).copyWith(color: colorScheme.onSurface),
                ),
              ),
              const SizedBox(height: 24),

              SectionCard(
                title: "Explore Tools",
                icon: Icons.explore_outlined,
                child: Column(
                  children: const [
                    ToolTile(
                      icon: Icons.upload_file,
                      title: "Document Analysis",
                      subtitle: "Upload and validate formatting",
                    ),
                    ToolTile(
                      icon: Icons.swap_horiz_outlined,
                      title: "Convertor",
                      subtitle: "Convert documents",
                    ),
                    ToolTile(
                      icon: Icons.insights_outlined,
                      title: "AI Feedback",
                      subtitle: "Get structured writing feedback",
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              Text(
                "Recent Analysis",
                style: AppTextStyles.subMidHeader(
                  context,
                ).copyWith(color: colorScheme.primary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
