# BitStat2 작업 진행 기록 (PROGRESS)

> 프로젝트 작업 이력을 시간순으로 기록한다. 최신 항목이 위로 오도록 작성.

---

## 2026-07-05 — 렌더 엔진/캐시 오류 해결 (전 페이지 렌더 복구)

### 증상
- `quarto preview`에서 `01_data/dist_discrete/` 등 다수 페이지가 **"Quarto Render Error"**(`ModuleNotFoundError: No module named 'yaml'`, jupyter 커널 기동 실패).

### 근본 원인 (2건)
1. **엔진 자동선택 폴백**: 모듈 문서는 `{shinylive-r}`/`{webr-r}` 셀만 있고 knitr `{r}` 셀이 없어, freeze 무효화 시 quarto가 **jupyter 엔진**을 골라 python(pyyaml)에 의존 → 이 환경엔 pyyaml 부재로 실패. `_quarto.yml`/`_metadata.yml`의 `engine:`은 자동선택을 **못 덮음**(문서 front matter나 `--metadata`만 유효).
2. **`.quarto` 캐시 손상**: `site_libs/quarto-contrib/shinylive` freeze 부분 손상 → `utime: No such file`/`Directory not empty`(iCloud 경로 취약성 §3.3과 연관).

### 조치
- 23개 모듈 `index.qmd` front matter에 **`engine: knitr`** 추가(+`_quarto.yml` 전역 `engine: knitr`로 랜딩 페이지 커버). 시도했던 `_metadata.yml` 방식은 엔진 자동선택을 못 덮어 폐기.
- **`.quarto` 캐시 삭제** 후 재렌더 → shinylive site_libs 재생성.

### 검증
- `quarto render` 전체 **39/39 파일 오류 0건 성공**(`Output created: docs/index.html`).
- 프리뷰(http://localhost:7771) 재기동 후 `dist_discrete` 정상: 제목·본문·카테고리·WEBR "Ready!"·라이선스 푸터("CC BY-NC-SA 4.0") 렌더 확인. Shiny 앱 iframe은 WASM 로딩(배포와 동일 동작).

### 산출물
- 수정: 23개 `*/*/index.qmd`(engine 추가), `_quarto.yml`(전역 engine), `docs/` 전체 재빌드, `PLAN.md`.

---

## 2026-07-05 — PLAN 실행 1차 (P0 폰트 범위 재확정 · P1 문서/라이선스/설정)

### 한 일
- **CLAUDE.md 확인**(이미 존재, 정본·폰트·모듈 규칙 반영됨).
- **P1 라이선스 정리(§3.5)**: `LICENSE`(GPL-3 전문), `LICENSE-content.md`(CC BY-NC-SA 4.0), `DATA_LICENSES.md`(Galton=퍼블릭도메인, k_penguins=palmerpenguins CC0 한글판) 생성. `_quarto.yml` `license:` 표기를 "콘텐츠 CC BY-NC-SA 4.0 · 코드 GPL-3.0"으로 정정.
- **P1 문서화(§3.6)**: 빈 `README.md`를 프로젝트 소개·기술스택·구조·로컬개발·컨벤션·라이선스로 작성. `CONTRIBUTING.md`(정본 위치·폰트·PR 체크리스트) 작성.
- **P1 애널리틱스(§3.4)**: 죽은 `UA-229551680-1`을 주석 처리 + GA4 교체 안내 주석 추가.
- **P3 설정 정리(§3.9)**: `_quarto.yml`의 `# - pyodide` 주석 필터 제거.
- **P0 폰트(§3.2)**: `x_score`의 `Tahoma` 제거(작업 트리) 확인, `engine: knitr`로 로컬 렌더 성공.

### 실측으로 새로 확정/교정한 사실 (배포 사이트 브라우저 검증 포함)
- **폰트 표준 동작 확인**: 배포 `05_infer/clt` 앱이 `library(showtext); showtext_auto()`만으로 한글 플롯 라벨("정규 분포의 PDF", "표본 평균의 분포")을 **정상 렌더**. → 표준 스니펫이 WASM에서 동작함을 실측.
- **§3.2 범위 축소**: 폰트 없는 모듈들의 shinylive **앱** 내부 한글 플롯 라벨 = **0건**(dist_continuous/lln 앱은 영어). 한글 플롯 라벨은 수동 실행 `{webr-r}` 코드셀에만 존재(예: lln은 `if(interactive())` 가드로 플롯 미생성). 자동 렌더 앱 기준 폴백 위험은 실질적으로 `x_score`의 Tahoma뿐이었고 이는 수정됨.
- **§3.10 시드 해소**: 정적 `{r}` 셀에 랜덤 사용 **0건**(모든 랜덤은 인터랙티브 shinylive/webr). "정적 렌더 재현성"용 set.seed 대상 없음.
- **§3.9 패키지 커버리지 실측**: `{webr-r}` 셀이 `library()`하는 패키지 중 **10개**(BSDA·GGally·RColorBrewer·broom·moments·palmerpenguins·purrr·tidytext·vcd·wordcloud2)가 `webr.packages`에 없음. 10개 모두 webR 저장소에 바이너리 존재 확인. 단, 전역 목록 추가는 모든 페이지 로딩 급증(§3.8) → **페이지별 지정**이 정답, 런타임 검증 후 적용 보류.
- **빌드 환경**: shinylive/webr 전용 문서는 freeze 무효화 시 quarto가 jupyter 엔진 선택 → 이 환경(pyyaml 부재)에서 실패. `--metadata engine=knitr`로 회피됨.

### 추가 실행 — P0-1 코드 정본화 완료 (소유자 지시로 삭제)
- **`shiny/` 폴더 전부 삭제**: 23개 폴더 / 27개 파일(`app.R` 23 + `06_reg/reg/shiny/styles.css` + `07_theory/lln`의 `app_balls.R`/`app_coin.R`/`app_dist.R`). 삭제 전 `*.qmd`·`*.yml`에서 `shiny/` 참조 **0건** 확인 → 빌드 무영향, `docs/` 산출물 무관(인라인 standalone 블록이라 원래 미포함).
- `CLAUDE.md` §1·구조도, `README.md`, `CONTRIBUTING.md`를 "인라인 블록 = 유일 정본, `shiny/` 폴더 생성 금지"로 갱신. → **drift 원천(§3.1) 제거 완료**.

### 소유자 결정 대기 (의도적 미실행)
- **P1 애널리틱스**: GA4 측정 ID 발급/기입 or 미사용 확정.
- **P1 CI(§3.7)**: GitHub Pages 배포 설정·시크릿 확인 필요.
- **P0-2 잔여**: 한글 그리는 webr 코드셀 showtext 적용(§10 패키지 작업과 결합, 런타임 검증 후).

### 산출물
- 신규: `README.md`(재작성), `CONTRIBUTING.md`, `LICENSE`, `LICENSE-content.md`, `DATA_LICENSES.md`
- 수정: `_quarto.yml`(license/analytics/pyodide), `PLAN.md`(체크·범위 재확정), `04_testing/x_score/index.qmd`(Tahoma 제거, 재렌더)

---

## 2026-07-05 — 기술검토 수행 및 적대적 재검증

### 한 일
- **프로젝트 전수 정적 분석**: 파일 구조, git 이력, `_quarto.yml`, 23개 Shiny 앱, 24개 콘텐츠 `index.qmd` 파악.
- **기술검토 보고서 작성**: `tech_document/2026-07-05_기술검토.md` 생성 — 잘된 점 7개, 문제점 12개(§3.1~3.12), 로드맵·우선순위·후속 과제 정리.
- **codex 독립 적대적 검토**로 초안 재검증 후 실측 재확인하여 교정.

### 실측으로 확정한 사실
- **코드 drift(§3.1)**: 인라인 shinylive 블록 vs `shiny/app.R` 전수 diff → **IDENTICAL 15 / DRIFT 8 / 누락 0**. 특히 `02_eda/univariate_stat`는 151줄 차이(사실상 다른 앱), `07_theory/lln` 18줄.
- **한글 폰트 비일관(§3.2)**: 배포되는 인라인 블록 24개 중 **15개만 `showtext` 사용**, 8개 폰트 설정 없음. `x_score`는 WASM에 없는 `Tahoma` 지정.
- **`{webr-r}` 셀**: 24개 파일에 **27개 블록** 존재(webr 활발히 사용 중).
- **CSV 업로드 앱**: 8개 모듈이 입력 검증 없이 `read.csv(input$file$datapath)`.
- **`set.seed`**: 전체 중 1개 모듈만 사용(랜덤 시뮬레이션 재현성 취약).
- **빌드 산출물**: `docs/`(77MB, 278파일)·`_freeze/`(28파일) git 커밋됨. 저장소는 iCloud Drive 내부 위치.
- **애널리틱스**: `UA-229551680-1`(Universal Analytics, 2023-07 종료 → 지표 수집 불가).

### 적대적 검토로 교정한 초안 결함
- (사실오류) "`{webr-r}` 셀 0개" → grep zsh glob 오류 오독. 실제 27개로 정정.
- (사실오류) "브라우저에서 패키지 컴파일" → 사전 컴파일 WASM 바이너리 다운로드로 정정.
- (과장) drift 3개 샘플 단정 → 전수 8/23로 재확정. 폰트 P0 → P1(픽셀 검증 후 승격).
- (누락) 재현성·보안(업로드)·접근성·데이터 라이선스 4영역 신설(§3.10~3.12).

### 산출물
- `tech_document/2026-07-05_기술검토.md`
- `PROGRESS.md`(본 파일), `PLAN.md`

### 다음 액션
- `PLAN.md`의 P0 항목부터 착수(코드 정본화, 폰트 표준화). 상세는 [PLAN.md](PLAN.md) 참조.
