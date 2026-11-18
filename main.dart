import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jivit_jal_2/Screens/CommonScreens/Auth/OnboardingScreen/OnboardingScreenOne.dart';
import 'package:jivit_jal_2/Utils/TokenRefreshService.dart';
import 'package:jivit_jal_2/bloc/franchise_agent/franchise_agent_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_cod/franchise_cod_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_inventory/franchise_inventory_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_live_agent/franchise_live_agent_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_agent_orders/franchise_agent_orders_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_order_detail/franchise_order_detail_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_order_list/franchise_order_list_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_order_view/franchise_order_view_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_order_action/franchise_order_action_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_plans/franchise_plans_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_customers/franchise_customers_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_customer_history/franchise_customer_history_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_customer_note/franchise_customer_note_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_auth/franchise_auth_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_bank/franchise_bank_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_dashboard/franchise_dashboard_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_profile/franchise_profile_bloc.dart';
import 'package:jivit_jal_2/bloc/franchise_zone/franchise_zone_bloc.dart';
import 'package:jivit_jal_2/bloc/rider_auth/rider_auth_bloc.dart';
import 'package:jivit_jal_2/bloc/rider_profile/rider_profile_bloc.dart';
import 'package:jivit_jal_2/bloc/rider_order_list/rider_order_list_bloc.dart';
import 'package:jivit_jal_2/bloc/rider_order_detail/rider_order_detail_bloc.dart';
import 'package:jivit_jal_2/bloc/rider_order_action/rider_order_action_bloc.dart';
import 'package:jivit_jal_2/bloc/rider_stats/rider_stats_bloc.dart';
import 'package:jivit_jal_2/data/repositories/auth_repository.dart';
import 'package:jivit_jal_2/data/repositories/franchise_repository.dart';
import 'package:jivit_jal_2/data/repositories/rider_repository.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final authRepository = AuthRepository();
    final franchiseRepository = FranchiseRepository();
    final riderRepository = RiderRepository();
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => FranchiseAuthBloc(authRepository)),
        BlocProvider(create: (_) => RiderAuthBloc(authRepository)),
        BlocProvider(create: (_) => RiderProfileBloc(riderRepository)),
        BlocProvider(create: (_) => RiderOrderListBloc(riderRepository)),
        BlocProvider(create: (_) => RiderOrderDetailBloc(riderRepository)),
        BlocProvider(create: (_) => RiderOrderActionBloc(riderRepository)),
        BlocProvider(create: (_) => RiderStatsBloc(riderRepository)),
        BlocProvider(create: (_) => FranchiseProfileBloc(franchiseRepository)),
        BlocProvider(create: (_) => FranchiseDashboardBloc(franchiseRepository)),
        BlocProvider(create: (_) => FranchiseBankBloc(franchiseRepository)),
        BlocProvider(create: (_) => FranchiseZoneBloc(franchiseRepository)),
        BlocProvider(create: (_) => FranchiseAgentBloc(franchiseRepository)),
        BlocProvider(create: (_) => FranchiseCodBloc(franchiseRepository)),
        BlocProvider(create: (_) => FranchiseInventoryBloc(franchiseRepository)),
        BlocProvider(create: (_) => FranchiseLiveAgentBloc(franchiseRepository)),
        BlocProvider(create: (_) => FranchiseAgentOrdersBloc(franchiseRepository)),
        BlocProvider(create: (_) => FranchiseOrderDetailBloc(franchiseRepository)),
        BlocProvider(create: (_) => FranchiseOrderListBloc(franchiseRepository)),
        BlocProvider(create: (_) => FranchiseOrderViewBloc(franchiseRepository)),
        BlocProvider(create: (_) => FranchiseOrderActionBloc(franchiseRepository)),
        BlocProvider(create: (_) => FranchisePlansBloc(franchiseRepository)),
        BlocProvider(create: (_) => FranchiseCustomersBloc(franchiseRepository)),
        BlocProvider(create: (_) => FranchiseCustomerHistoryBloc(franchiseRepository)),
        BlocProvider(create: (_) => FranchiseCustomerNoteBloc(franchiseRepository)),
      ],
      child: MaterialApp(
        title: 'Jivit Jal Franchise/Rider',
        navigatorKey: TokenRefreshService.navigatorKey,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        initialRoute: '/',
        routes: {
          '/': (_) => const SafeArea(
                top: true,
                bottom: true,
                child: OnboardingScreenOne(),
              ),
        },
      ),
    );
  }
}
