import 'package:df_bus/services/service_locator.dart';
import 'package:df_bus/value_notifiers/theme_notifier.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLinesResult extends StatelessWidget {
  const SkeletonLinesResult({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = getIt<ThemeNotifier>();
    final color = themeNotifier.isDarkMode
        ? Colors.amber
        : Theme.of(context).colorScheme.primary;
    return ListView.builder(
      itemCount: 7,
      itemBuilder: (context, index) {
        return Card(
          color: Theme.of(context).colorScheme.tertiary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(9),
          ),
          elevation: 3,
          child: Container(
              decoration: BoxDecoration(
                border: Border(
                  left: BorderSide(color: color, width: 7),
                ),
                borderRadius: BorderRadius.circular(9),
              ),
              child: Shimmer.fromColors(
                baseColor: Colors.grey,
                highlightColor: Colors.white,
                child: ListTile(
                  contentPadding: EdgeInsets.only(left: 7, right: 7),
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                        ),
                        width: 40,
                        height: 25,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white,
                                ),
                                height: 20,
                              ),
                              SizedBox(height: 7),
                              Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(15),
                                  color: Colors.white,
                                ),
                                width: 75,
                                height: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white,
                        ),
                        width: 50,
                        height: 25,
                      ),
                    ],
                  ),
                  trailing: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: Colors.white,
                    ),
                    width: 24,
                    height: 24,
                  ),
                ),
              )),
        );
      },
    );
  }
}
