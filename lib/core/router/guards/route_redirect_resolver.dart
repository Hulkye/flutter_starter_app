import '../definitions/app_route_target.dart';
import 'internal_route_location.dart';
import 'route_access_decision.dart';

/// 根据当前 location 和最终访问决策计算重定向目标。
String? resolveAccessRedirect({
  required String currentLocation,
  required String matchedRoutePath,
  required RouteAccessDecision decision,
  List<String> publicPaths = const <String>['/'],
  String redirectQueryParameter = 'redirect',
}) {
  final currentUri = Uri.parse(currentLocation);

  return switch (decision) {
    AllowRoute(:final redirects) => _resolveAllowedRedirect(
      matchedRoutePath,
      redirects,
    ),
    RedirectRoute(
      :final target,
      :final preserveTarget,
      :final appliesToPublicRoutes,
    ) => _resolveRequiredRedirect(
      currentUri: currentUri,
      matchedRoutePath: matchedRoutePath,
      targetLocation: target.location,
      preserveTarget: preserveTarget,
      appliesToPublicRoutes: appliesToPublicRoutes,
      publicPaths: publicPaths,
      redirectQueryParameter: redirectQueryParameter,
    ),
  };
}

/// 只允许回跳到当前应用内的根路径。
String? readInternalRedirect(String? value) {
  if (value == null || value.isEmpty || !isInternalLocation(value)) return null;
  return Uri.parse(requireInternalLocation(value)).toString();
}

String? _resolveAllowedRedirect(
  String matchedRoutePath,
  Map<String, AppRouteTarget> redirects,
) {
  for (final entry in redirects.entries) {
    requireInternalLocation(entry.key);
    requireInternalLocation(entry.value.location);
    if (entry.key == matchedRoutePath) return entry.value.location;
  }
  return null;
}

String? _resolveRequiredRedirect({
  required Uri currentUri,
  required String matchedRoutePath,
  required String targetLocation,
  required bool preserveTarget,
  required bool appliesToPublicRoutes,
  required List<String> publicPaths,
  required String redirectQueryParameter,
}) {
  requireInternalLocation(targetLocation);
  final targetUri = Uri.parse(targetLocation);
  if (targetUri.path == currentUri.path) return null;

  final isPublic = publicPaths.contains(matchedRoutePath);
  if (isPublic && !appliesToPublicRoutes) return null;
  if (!preserveTarget) return targetLocation;

  return targetUri
      .replace(
        queryParameters: <String, String>{
          ...targetUri.queryParameters,
          redirectQueryParameter: currentUri.toString(),
        },
      )
      .toString();
}