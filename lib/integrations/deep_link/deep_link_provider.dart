import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_starter_app/core/capability/app_capability.dart';

import 'application/deep_link_coordinator.dart';

/// Deep Link 能力 Provider。
Provider<DeepLinkCapability> get deepLinkCapabilityProvider =>
    deepLinkCoordinatorProvider;
