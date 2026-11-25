import 'package:chantier_mobile/core/api/generated/export.dart';
import 'package:chantier_mobile/core/config/app_config.dart';
import 'package:chantier_mobile/core/network/api_exception.dart';
import 'package:chantier_mobile/core/network/dio_client.dart';

/// Clients generes depuis `docs/api/openapi.json` (swagger_parser + retrofit, ADR 0006),
/// branches sur le [DioClient] : memes intercepteurs d'authentification et de langue.
///
/// Les appels doivent passer par [guard] pour que toute erreur ressorte en [ApiException].
class ApiClients {
  ApiClients({required AppConfig config, required DioClient dioClient})
    : auth = AuthClient(dioClient.dio, baseUrl: config.serverRootUrl),
      anonymousAuth = AuthClient(
        dioClient.bareDio,
        baseUrl: config.serverRootUrl,
      ),
      sync = SyncClient(dioClient.dio, baseUrl: config.serverRootUrl),
      sites = SitesClient(dioClient.dio, baseUrl: config.serverRootUrl),
      zones = ZonesClient(dioClient.dio, baseUrl: config.serverRootUrl),
      siteMembers = SiteMembersClient(
        dioClient.dio,
        baseUrl: config.serverRootUrl,
      ),
      reference = ReferenceClient(dioClient.dio, baseUrl: config.serverRootUrl);

  /// Routes authentifiees : `me`, `logout`, `change-password`, langue.
  final AuthClient auth;

  /// Routes **anonymes** (`login`, `refresh`) : client nu, sans Bearer ni rejeu apres 401.
  final AuthClient anonymousAuth;
  final SyncClient sync;
  final SitesClient sites;
  final ZonesClient zones;
  final SiteMembersClient siteMembers;
  final ReferenceClient reference;

  /// Execute un appel genere et convertit toute erreur en [ApiException].
  static Future<T> guard<T>(Future<T> Function() call) => DioClient.guard(call);
}
