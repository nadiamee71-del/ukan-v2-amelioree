import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import 'coach_personality_model.dart';
import 'html_audio_helper_stub.dart'
    if (dart.library.html) 'html_audio_helper_web.dart';

/// Service pour gérer la lecture audio des coaches (mode démo)
class CoachAudioService {
  static final CoachAudioService _instance = CoachAudioService._internal();
  factory CoachAudioService() => _instance;
  CoachAudioService._internal() {
    // Écouter les événements de fin de lecture
    _audioPlayer.onPlayerComplete.listen((_) {
      _isPlaying = false;
      debugPrint('✅ Audio terminé');
    });
    
    // Écouter les erreurs de lecture
    _audioPlayer.onLog.listen((message) {
      debugPrint('🔊 AudioPlayer log: $message');
    });
    
    // Écouter les changements d'état
    _audioPlayer.onPlayerStateChanged.listen((state) {
      debugPrint('🔊 État du lecteur changé: $state');
      if (state == PlayerState.playing) {
        debugPrint('✅ Audio en cours de lecture !');
      } else if (state == PlayerState.completed) {
        debugPrint('✅ Audio terminé');
        _isPlaying = false;
      } else if (state == PlayerState.paused) {
        debugPrint('⏸️ Audio en pause');
      } else if (state == PlayerState.stopped) {
        debugPrint('⏹️ Audio arrêté');
        _isPlaying = false;
      }
    });
  }

  final AudioPlayer _audioPlayer = AudioPlayer();
  AudioPlayer? _currentPlayer; // Lecteur actif pour mobile
  final HtmlAudioHelper _htmlHelper = HtmlAudioHelper();
  dynamic _htmlAudioElement; // Audio HTML5 natif pour mobile web (web uniquement)
  bool _isPlaying = false;
  bool _hasUserInteracted = false; // Pour le web, nécessite une interaction utilisateur

  /// Indique si un audio est en cours de lecture
  bool get isPlaying => _isPlaying;

  /// Marque qu'une interaction utilisateur a eu lieu (nécessaire pour le web)
  void markUserInteraction() {
    if (!_hasUserInteracted) {
      _hasUserInteracted = true;
      debugPrint('✅ Interaction utilisateur détectée - audio activé');
      
      // Sur le web, créer un élément audio silencieux pour "débloquer" l'audio
      // C'est une astuce pour contourner les restrictions des navigateurs
      if (kIsWeb) {
        try {
          final audio = _htmlHelper.createAudioElement();
          if (audio == null) {
            debugPrint('⚠️ Impossible de créer un élément audio (helper null)');
            return;
          }
          audio.src = 'data:audio/wav;base64,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';
          audio.volume = 0.0; // Silencieux
          final playPromise = audio.play();
          if (playPromise != null) {
            playPromise.then((_) {
              audio.pause();
              audio.remove();
              debugPrint('✅ Audio débloqué avec succès');
            }).catchError((e) {
              debugPrint('⚠️ Erreur déblocage audio: $e');
            });
          }
        } catch (e) {
          debugPrint('⚠️ Impossible de débloquer audio: $e');
        }
      }
    }
  }

  /// Joue un fichier audio aléatoire pour un coach donné
  Future<void> playRandomAudio(CoachPersonality coach) async {
    if (coach.audioPaths.isEmpty) {
      debugPrint('⚠️ Aucun fichier audio disponible pour ${coach.name}');
      return;
    }

    // Sur le web, nécessite une interaction utilisateur
    if (kIsWeb && !_hasUserInteracted) {
      debugPrint('⚠️ Web: Interaction utilisateur requise avant de jouer l\'audio');
      // On marque quand même l'interaction si l'utilisateur a démarré l'exercice
      _hasUserInteracted = true;
    }

    try {
      // Arrêter l'audio en cours s'il y en a un (sans attendre pour éviter les blocages)
      stop().catchError((e) {
        debugPrint('⚠️ Erreur lors de l\'arrêt de l\'audio précédent: $e');
      });

      // Sélectionner un fichier audio aléatoire
      final random = Random();
      final audioPath = coach.audioPaths[random.nextInt(coach.audioPaths.length)];
      debugPrint('🎵 Tentative de lecture: $audioPath');
      debugPrint('🎵 Nombre de fichiers audio disponibles: ${coach.audioPaths.length}');

      // Jouer l'audio
      _isPlaying = true;
      
      if (kIsWeb) {
        // Sur le web, utiliser UrlSource avec le chemin complet depuis la racine
        // Les fichiers sont dans build/web/assets/assets/audios/...
        // Flutter web duplique le dossier assets, donc l'URL doit être /assets/assets/audios/...
        // audioPath est déjà "assets/audios/...", on doit ajouter un "assets/" au début
        final webPath = audioPath.startsWith('assets/') 
            ? 'assets/$audioPath' // Ajouter "assets/" si pas déjà présent
            : 'assets/$audioPath';
        // Encoder les espaces pour l'URL web
        final encodedPath = webPath.replaceAll(' ', '%20');
        
        // Sur le web, toujours utiliser l'URL complète pour être sûr que ça fonctionne sur mobile
        // Les navigateurs mobiles sont très stricts avec les URLs relatives
        final baseUrl = _getBaseUrl();
        final urlPath = baseUrl.isNotEmpty 
            ? '$baseUrl/$encodedPath'
            : '/$encodedPath'; // Fallback si baseUrl vide
        
        debugPrint('🎵 Chemin web original: $webPath');
        debugPrint('🎵 Chemin web encodé: $encodedPath');
        debugPrint('🎵 URL complète: $urlPath');
        debugPrint('🎵 Base URL: $baseUrl');
        
        try {
          // Sur mobile web, essayer d'abord avec l'API HTML5 Audio native
          // C'est plus fiable que audioplayers sur Safari mobile
          debugPrint('🔄 Tentative avec HTML5 Audio natif: $urlPath');
          
          try {
            // Arrêter l'audio HTML5 précédent s'il existe
            _htmlAudioElement?.pause();
            _htmlAudioElement = null;
            
            // Créer un nouvel élément audio HTML5
            final audio = _htmlHelper.createAudioElement();
            if (audio == null) {
              throw Exception('Impossible de créer un élément audio HTML5');
            }
            audio.src = urlPath;
            audio.preload = 'auto';
            audio.crossOrigin = 'anonymous'; // Important pour CORS
            
            // Écouter les événements
            audio.onEnded.listen((_) {
              debugPrint('✅ Audio HTML5 terminé');
              _isPlaying = false;
              _htmlAudioElement = null;
            });
            
            audio.onError.listen((e) {
              debugPrint('❌ Erreur audio HTML5: $e');
              debugPrint('❌ Code erreur: ${audio.error?.code}');
              debugPrint('❌ Message erreur: ${audio.error?.message}');
              _isPlaying = false;
              _htmlAudioElement = null;
            });
            
            audio.onCanPlay.listen((_) {
              debugPrint('✅ Audio HTML5 prêt à jouer');
            });
            
            audio.onLoadedData.listen((_) {
              debugPrint('✅ Audio HTML5: données chargées');
            });
            
            audio.onPlaying.listen((_) {
              debugPrint('✅ Audio HTML5: en cours de lecture');
            });
            
            audio.onPause.listen((_) {
              debugPrint('⏸️ Audio HTML5: en pause');
            });
            
            // Attendre que l'audio soit prêt avant de jouer (avec timeout)
            try {
              await audio.onCanPlay.first.timeout(
                const Duration(seconds: 5),
              );
            } catch (e) {
              debugPrint('⚠️ Timeout ou erreur lors de l\'attente: $e');
              // Continuer quand même, l'audio pourrait être prêt
            }
            
            // Jouer l'audio
            debugPrint('🎵 Tentative de lecture HTML5...');
            final playPromise = audio.play();
            if (playPromise != null) {
              await playPromise.then((_) {
                debugPrint('✅ Audio HTML5 play() réussi');
                _isPlaying = true;
              }).catchError((error) {
                debugPrint('❌ Erreur play() HTML5: $error');
                debugPrint('❌ Type erreur: ${error.runtimeType}');
                _isPlaying = false;
                _htmlAudioElement = null;
              });
            } else {
              debugPrint('⚠️ play() a retourné null');
              _isPlaying = true; // On suppose que ça fonctionne
            }
            
            _htmlAudioElement = audio;
            debugPrint('✅ Audio HTML5 lancé avec succès');
            
            // Vérifier après un délai
            await Future.delayed(const Duration(milliseconds: 1000));
            if (audio.paused && !audio.ended) {
              debugPrint('⚠️ Audio HTML5 toujours en pause, nouvelle tentative...');
              debugPrint('⚠️ État: paused=${audio.paused}, ended=${audio.ended}, readyState=${audio.readyState}');
              final retryPromise = audio.play();
              if (retryPromise != null) {
                await retryPromise.then((_) {
                  debugPrint('✅ Retry play() réussi');
                }).catchError((error) {
                  debugPrint('❌ Erreur retry play() HTML5: $error');
                });
              }
            }
            
            return; // Succès avec HTML5 Audio
          } catch (htmlError) {
            debugPrint('❌ Erreur avec HTML5 Audio: $htmlError');
            // Fallback vers audioplayers
          }
          
          // Fallback: utiliser audioplayers
          debugPrint('🔄 Fallback vers audioplayers: $urlPath');
          await _audioPlayer.play(UrlSource(urlPath));
          debugPrint('✅ Play() audioplayers appelé');
          
          // Vérifier l'état après un court délai
          await Future.delayed(const Duration(milliseconds: 300));
          final state = _audioPlayer.state;
          debugPrint('🔊 État du lecteur après play(): $state');
          
          if (state == PlayerState.paused || state == PlayerState.stopped) {
            // Si toujours en pause, essayer resume()
            debugPrint('🔄 État en pause, tentative de resume()');
            await _audioPlayer.resume();
            debugPrint('✅ Resume() appelé');
          }
        } catch (urlError) {
          debugPrint('❌ Erreur avec UrlSource + play(): $urlError');
          // Fallback 1: Essayer setSource + play
          try {
            debugPrint('🔄 Fallback 1: setSource + play');
            await _audioPlayer.setSource(UrlSource(urlPath));
            await Future.delayed(const Duration(milliseconds: 300));
            await _audioPlayer.play(UrlSource(urlPath));
            debugPrint('✅ setSource + play réussi');
          } catch (setSourceError) {
            debugPrint('❌ Erreur avec setSource + play: $setSourceError');
            // Fallback 2: Essayer avec AssetSource
            try {
              final assetPath = audioPath.replaceFirst('assets/', '');
              debugPrint('🔄 Fallback 2: AssetSource - $assetPath');
              await _audioPlayer.play(AssetSource(assetPath));
              debugPrint('✅ AssetSource + play réussi');
            } catch (assetError) {
              debugPrint('❌ Erreur avec AssetSource: $assetError');
              // Dernier essai: setSource + resume avec AssetSource
              try {
                final assetPath = audioPath.replaceFirst('assets/', '');
                await _audioPlayer.setSource(AssetSource(assetPath));
                await Future.delayed(const Duration(milliseconds: 300));
                await _audioPlayer.resume();
                debugPrint('✅ AssetSource setSource + resume réussi');
              } catch (finalError) {
                debugPrint('❌ Toutes les méthodes ont échoué: $finalError');
                rethrow;
              }
            }
          }
        }
      } else {
        // Sur mobile, utiliser AssetSource sans "assets/"
        final assetPath = audioPath.replaceFirst('assets/', '');
        debugPrint('🎵 Chemin mobile: $assetPath');
        await _audioPlayer.play(AssetSource(assetPath));
      }
      
      debugPrint('✅ Audio lancé avec succès');
    } catch (e, stackTrace) {
      _isPlaying = false;
      debugPrint('❌ Erreur lecture audio: $e');
      debugPrint('❌ Stack trace: $stackTrace');
    }
  }

  /// Arrête la lecture audio en cours
  Future<void> stop() async {
    try {
      // Arrêter l'audio HTML5 si actif
      if (_htmlAudioElement != null) {
        _htmlAudioElement!.pause();
        _htmlAudioElement!.src = '';
        _htmlAudioElement = null;
        debugPrint('✅ Audio HTML5 arrêté');
      }
      
      if (_currentPlayer != null) {
        await _currentPlayer!.stop();
        await _currentPlayer!.dispose();
        _currentPlayer = null;
      }
      await _audioPlayer.stop();
      _isPlaying = false;
    } catch (e) {
      _isPlaying = false;
      debugPrint('Erreur arrêt audio: $e');
    }
  }

  /// Libère les ressources
  void dispose() {
    if (_htmlAudioElement != null) {
      _htmlAudioElement!.pause();
      _htmlAudioElement!.src = '';
      _htmlAudioElement = null;
    }
    _currentPlayer?.dispose();
    _audioPlayer.dispose();
  }
  
  /// Détecte si on est sur un appareil mobile
  bool _isMobileDevice() {
    if (!kIsWeb) return false;
    // Détection via la taille de l'écran (approximation)
    // Sur mobile, la largeur est généralement < 768px
    // Mais comme on est dans un service, on ne peut pas accéder à MediaQuery
    // On va toujours utiliser l'URL complète pour être sûr
    return true; // Par sécurité, on suppose mobile pour forcer l'URL complète
  }
  
  /// Obtient l'URL de base pour les fichiers audio
  String _getBaseUrl() {
    if (!kIsWeb) return '';
    final origin = _htmlHelper.getWindowOrigin();
    if (origin == null) {
      debugPrint('⚠️ Impossible de récupérer l\'origine (helper null)');
      return '';
    }
    debugPrint('🌐 URL de base détectée: $origin');
    return origin;
  }
}

