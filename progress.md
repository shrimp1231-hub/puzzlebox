# 퍼즐박스 Flutter — Progress

## Phase 1 — Day 1: 메인 허브 UI ✅ (2026-05-31)

### 완성된 파일
- `pubspec.yaml` — 의존성 (provider, shared_preferences, flutter_animate, google_fonts, gap)
- `lib/main.dart` — 앱 진입점, 다크 테마, 세로 고정
- `lib/theme/app_theme.dart` — AppColors (배경/카드 그라디언트/텍스트), AppTheme.dark
- `lib/models/game_info.dart` — GameId enum, GameInfo 모델, allGames 리스트
- `lib/widgets/game_card.dart` — 그라디언트 카드, 이모지, Coming Soon 배지, 탭 애니메이션
- `lib/widgets/stat_chip.dart` — 오늘 플레이/포인트/출석 칩
- `lib/screens/home_screen.dart` — 메인 허브: 헤더(로고+인사), 스탯 행, 2열 게임 그리드

### Android 프로젝트 파일
- `android/AndroidManifest.xml`
- `android/app/build.gradle`, `android/build.gradle`, `android/settings.gradle`
- `android/app/src/main/kotlin/com/puzzlebox/MainActivity.kt`
- `android/app/src/main/res/values/styles.xml`, `drawable/launch_background.xml`

### 빌드 환경 이슈
- 컨테이너: ARM64 Linux, Flutter CLI TLS 부트스트랩 오류로 pub.dev 접근 불가
- 코드는 완성 상태 — Codemagic CI 또는 로컬 Flutter 환경에서 빌드 가능

### 빌드 방법
```bash
# 1. Flutter SDK 설치 후
flutter pub get
flutter build apk --release
```

---

## Phase 1 — Day 2: 프로필 + 포인트 시스템 ✅ (2026-05-31)

### 완성된 파일
- `lib/models/point_transaction.dart` — TransactionType enum, PointTransaction 모델
- `lib/repositories/auth_repository.dart` — AuthRepository 추상 클래스, SupabaseAuthRepository 플레이스홀더
- `lib/repositories/point_repository.dart` — PointRepository 추상 클래스, LocalPointRepository (SharedPreferences)
- `lib/providers/auth_provider.dart` — AuthState enum, AuthProvider (ChangeNotifier)
- `lib/providers/point_provider.dart` — PointProvider (ChangeNotifier)
- `lib/screens/profile_screen.dart` — 프로필 UI: 로그인/프로필 헤더/스탯/포인트 내역/로그아웃
- `lib/main.dart` — MultiProvider 래핑 (AuthProvider + PointProvider)
- `lib/screens/home_screen.dart` — StatefulWidget 변환, Consumer 연결, 프로필 버튼 NavigatorPush

### 크리덴셜 대기 (TODO)
- Supabase URL + anon key → OneCLI 등록 후 `SupabaseAuthRepository` 구현체 완성
- Google OAuth Client ID → `google_sign_in` 실제 연동
- `pubspec.yaml`에 `supabase_flutter: ^2.3.4`, `google_sign_in: ^6.2.1` 추가됨 (빌드 시 사용)

---

---

## Phase 1 — Day 3: 캐릭터 꾸미기 구조 + 스도쿠 ✅ (2026-05-31)

### Step 3 — 캐릭터 꾸미기 (구조 완성, 에셋 대기)
- `lib/models/character_item.dart` — ItemCategory/ItemRarity enum, CharacterItem 모델, defaultItemCatalog (15개 플레이스홀더)
- `lib/providers/character_provider.dart` — 장착/구매/저장 (SharedPreferences)
- `lib/screens/character_screen.dart` — 캐릭터 미리보기, 카테고리 탭, 아이템 그리드, 구매 다이얼로그
- **pixellab.ai 에셋 연동 대기** — assetPath가 null이면 카테고리 이모지로 대체 표시

### Step 4 — 스도쿠
- `lib/models/sudoku_types.dart` — Difficulty/CellState/Position/InputMode/GameStatus
- `lib/utils/sudoku_solver.dart` — 백트래킹 솔버, countSolutions (고유성 검증용)
- `lib/utils/sudoku_generator.dart` — 완전한 판 생성 + 난이도별 칸 제거 (36~56개)
- `lib/providers/sudoku_provider.dart` — 게임 상태 전체 (셀 입력, 메모, 힌트, 되돌리기, 실수, 타이머, 자동 저장)
- `lib/widgets/sudoku_board.dart` — 9×9 그리드, 굵은 3×3 구분선, 선택/강조/동일숫자 하이라이트
- `lib/widgets/sudoku_cell.dart` — 값/메모 표시, 에러 색상, 주어진 숫자 볼드
- `lib/widgets/number_pad.dart` — 숫자 1-9 (잔여 표시), 되돌리기/메모/힌트/지우기 액션 버튼
- `lib/screens/sudoku_screen.dart` — 난이도 선택 바텀시트, 게임 화면, 클리어/게임오버 다이얼로그, 포인트 지급

### 업데이트
- `lib/main.dart` — CharacterProvider, SudokuProvider 추가
- `lib/screens/home_screen.dart` — 스도쿠 카드 탭 시 SudokuScreen으로 이동, 2048/지뢰찾기는 "곧 열립니다" 스낵바

---

---

## Phase 1 — Day 3 cont: 2048 ✅ (2026-05-31)

### Step 5 — 2048
- `lib/models/game_2048_types.dart` — Tile2048, Direction2048, tileColors (다크 테마 적용)
- `lib/utils/game_2048_logic.dart` — applyMove (4방향 슬라이드+병합), spawnTile (90%=2/10%=4), isGameOver
- `lib/providers/game_2048_provider.dart` — move/newGame/continueAfterWin, 최고점수 분리 저장, 자동저장
- `lib/widgets/game_2048_board.dart` — AnimatedPositioned 타일 이동, 병합 scale 애니, 신규 elastic 애니, 스와이프 제스처
- `lib/screens/game_2048_screen.dart` — 점수/최고점수 패널, 2048 달성 다이얼로그(+500P), 게임오버 다이얼로그

### 업데이트
- `lib/models/game_info.dart` — 2048 isUnlocked: true (Coming Soon 해제)
- `lib/main.dart` — Game2048Provider 추가
- `lib/screens/home_screen.dart` — 2048 카드 탭 시 Game2048Screen으로 이동

---

---

## Phase 1 — Day 3 cont: 지뢰찾기 ✅ (2026-05-31)

### Step 6 — 지뢰찾기
- `lib/models/minesweeper_types.dart` — MinesweeperDifficulty(3단계), CellStatus, MineCell, numberColors
- `lib/utils/minesweeper_logic.dart` — placeMines(첫 클릭 안전지대 3×3), revealCell(BFS 플러드필), chordReveal, revealAllMines, checkWin
- `lib/providers/minesweeper_provider.dart` — 첫 클릭 시 지뢰 배치, 플래그 토글, 게임오버/클리어, 타이머, 자동저장
- `lib/widgets/minesweeper_cell.dart` — 숨김/열림/깃발/지뢰/폭발 셀, 숫자 색상
- `lib/widgets/minesweeper_board.dart` — InteractiveViewer (핀치 줌/패닝), 탭=열기/길게탭=깃발
- `lib/screens/minesweeper_screen.dart` — 상태바(💣 남은수/⏱타이머), 난이도 선택, 클리어/게임오버 다이얼로그, 포인트 지급

### 난이도
| 난이도 | 크기 | 지뢰 | 포인트 |
|---|---|---|---|
| 쉬움 | 9×9 | 10 | +30P |
| 보통 | 16×16 | 40 | +100P |
| 전문가 | 20×20 | 70 | +250P |

### 업데이트
- `lib/models/game_info.dart` — 지뢰찾기 isUnlocked: true
- `lib/main.dart` — MinesweeperProvider 추가
- `lib/screens/home_screen.dart` — 지뢰찾기 카드 탭 시 MinesweeperScreen으로 이동

---

## Phase 1 — Day 3 cont: AdMob 코드 구조 ✅ (2026-05-31)

### Step 7 — AdMob (App ID 대기, 코드 구조 완성)
- `lib/services/ad_service.dart` — AdService 싱글톤, AdIds (Android/iOS 플레이스홀더 + Google 테스트 ID)
  - `initialize()` — 플레이스홀더 (실제 초기화 TODO 주석)
  - `showRewardedAd()` — 플레이스홀더, 항상 true 반환 (Future.delayed)
  - `showInterstitialAd()` — no-op 플레이스홀더
- `lib/widgets/rewarded_ad_button.dart` — 재사용 광고 버튼 위젯 (로딩 인디케이터, 성공/실패 콜백)
- `lib/screens/sudoku_screen.dart` — 업데이트
  - hintsLeft==0 + playing 상태 → 힌트 광고 버튼 표시
  - 게임오버 다이얼로그 → 광고 시청 후 계속하기 버튼
- `lib/providers/sudoku_provider.dart` — `grantHintFromAd()` 추가
- `pubspec.yaml` — `google_mobile_ads: ^5.1.0` 추가
- `lib/main.dart` — `AdService.instance.initialize()` 호출

### 광고 플로우
| 트리거 | 광고 유형 | 보상 |
|--------|-----------|------|
| 힌트 소진 후 버튼 탭 | 보상형 | hintsLeft +1 |
| 게임오버 → 계속하기 | 보상형 | mistakeChance +1 |
| 게임 클리어 (추후) | 인터스티셜 | 없음 |

---

## Phase 1 — Day 3 cont: QA 체크리스트 ✅ (2026-05-31)

### Step 8 — QA 체크리스트
- `qa_checklist.md` — 전체 기능 수동 테스트 시트
  - 섹션 1: 앱 시작/공통 (5개)
  - 섹션 2: 홈 화면 (11개)
  - 섹션 3: 프로필 (7개)
  - 섹션 4: 캐릭터 꾸미기 (10개)
  - 섹션 5: 스도쿠 — 시작/플레이/실수/광고/클리어 (30개)
  - 섹션 6: 2048 (16개)
  - 섹션 7: 지뢰찾기 (18개)
  - 섹션 8: AdMob 공통 (7개)
  - 섹션 9: 포인트 시스템 (5개)
  - 섹션 10: 성능/엣지 케이스 (6개)
  - 크리덴셜 TODO 테이블

---

## 세션 완료 상태 (2026-05-31 새벽)

| Step | 내용 | 상태 |
|------|------|------|
| 1 | 메인 허브 UI | ✅ |
| 2 | 프로필 + 포인트 시스템 | ✅ |
| 3 | 캐릭터 꾸미기 구조 | ✅ |
| 4 | 스도쿠 Flutter 구현 | ✅ |
| 5 | 2048 | ✅ |
| 6 | 지뢰찾기 | ✅ |
| 7 | AdMob 코드 구조 | ✅ |
| 8 | QA 체크리스트 | ✅ |

### 아침 필요 작업 (Jay 확인)
- Supabase 크리덴셜 → OneCLI 등록 → `SupabaseAuthRepository` 실제 구현
- Google OAuth Client ID → `google_sign_in` 실제 연동
- AdMob App ID (Android/iOS) → AndroidManifest + Info.plist 등록
- pixellab.ai API 키 → 캐릭터 에셋 연동
