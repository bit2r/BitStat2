# BitStat2 개선 실행 계획 (PLAN)

> 근거: [tech_document/2026-07-05_기술검토.md](tech_document/2026-07-05_기술검토.md)
> 진행 기록: [PROGRESS.md](PROGRESS.md)
> 상태 표기: `[ ]` 미착수 · `[~]` 진행중 · `[x]` 완료

---

## 우선순위 개요

| 우선순위 | 목표 | 관련 이슈 |
|---------|------|-----------|
| **P0** | 정확성·신뢰 회복 | 코드 정본화(§3.1), 한글 폰트 표준화(§3.2) |
| **P1** | 배포·법적·지표 안정화 | 애널리틱스(§3.4), 라이선스(§3.5), README/CI/재현성(§3.6·3.7·3.10) |
| **P2** | 견고성·포용성·안전 | 업로드 가드(§3.11), 접근성(§3.12), 저장소 이전(§3.3) |
| **P3** | 성능·정돈 | 패키지 슬림화(§3.8), 설정 정리(§3.9) |

---

## P0 — 즉시 (정확성)

### 1. 코드 정본화 (§3.1) — **완료**
- [x] 정본을 **`index.qmd` 인라인 shinylive 블록**으로 확정 → `CLAUDE.md` §1, `README.md`, `CONTRIBUTING.md`에 명시 완료.
- [x] **`shiny/` 폴더 전부 삭제**(23개 폴더 / 27개 파일: app.R 23 + `reg/shiny/styles.css` + `lln` 보조앱 3). 삭제 전 qmd·yml에서 참조 0건 확인 → 빌드 영향 없음. `docs/` 산출물 무관.
- **완료 기준 충족**: `shiny/*.R` 소스 폴더 제거 완료(drift 원천 제거). 앱 소스는 인라인 블록 단일.

### 2. 한글 폰트 표준화 (§3.2) — **범위 재확정 완료(2026-07-05)**
- [x] 표준 스니펫 확정: `library(showtext); showtext_auto()`. **배포 사이트(`05_infer/clt`)에서 한글 플롯 라벨 정상 렌더 실측 확인** → 이 패턴이 shinylive/WASM에서 동작함.
- [x] `x_score`의 `Tahoma`(WASM 부재) 제거(작업 트리 반영). `engine: knitr`로 로컬 렌더 성공 확인.
- [x] **범위 재확정**: "폰트 없음 8개" 중 shinylive **앱** 내부에 한글 플롯 라벨을 그리는 모듈은 **0개**(모두 영어/사용자데이터 라벨). 한글 플롯 라벨은 수동 실행 `{webr-r}` 코드셀에만 존재 → 자동 렌더 앱 기준 폴백 위험 없음. §3.2는 보고서보다 좁음.
- [ ] (잔여) 한글 그리는 `{webr-r}` 코드셀(`dist_fitting`, `multivariate_stat`)에 showtext 스니펫 적용 — **페이지별 webr 패키지 지정 필요**(아래 §10과 결합), 런타임 Run-Code 검증 후.
- **완료 기준**: 자동 렌더 앱 = 충족. 코드셀 견고성은 §10 패키지 작업과 함께.

---

## P1 — 단기 (배포·법적·지표)

### 3. 애널리틱스 교체 (§3.4)
- [x] `_quarto.yml`의 죽은 `UA-229551680-1` 주석 처리 + GA4 교체 안내 주석 추가(지표 수집 불가 상태 제거).
- [ ] (사용자 결정) GA4 속성 발급 후 `G-XXXXXXX` 측정 ID 기입·주석 해제, 또는 애널리틱스 미사용 확정.

### 4. 라이선스 정리 (§3.5) — **완료**
- [x] 대상별 분리 확정: 코드=GPL-3.0, 콘텐츠=CC BY-NC-SA 4.0.
- [x] 루트에 `LICENSE`(GPL-3 전문) + `LICENSE-content.md`(CC BY-NC-SA 4.0) 추가, `_quarto.yml` `license:` 표기 정정.
- [x] `data/` 파일 출처·원저작자·라이선스·변형 여부를 `DATA_LICENSES.md`로 분리(Galton=퍼블릭도메인, k_penguins=palmerpenguins CC0 한글판).

### 5. 문서화 + CI + 재현성 (§3.6·3.7·3.10)
- [x] `README.md` 작성: 프로젝트 소개, 로컬 렌더, 배포 흐름, 모듈 추가 규칙, 폰트/패키지 컨벤션, 라이선스.
- [x] `CONTRIBUTING.md` 작성(정본 위치·폰트·PR 체크리스트).
- [ ] (사용자 결정) GitHub Actions 도입: Pages 배포 설정·시크릿 확인 필요 → 결정 대기.
- [ ] `renv.lock`(또는 pak) + Quarto 버전 핀으로 패키지 고정.
- [ ] `03_viz/viz`의 원격 CSV `download.file` → 저장소 내 스냅샷으로 고정(브라우저 fetch 구조라 별도 검토).
- [x] **정적 예제 랜덤 코드 스캔 결과: 정적 `{r}` 셀에 랜덤 사용 0건** → set.seed 대상 없음(모든 랜덤은 인터랙티브 shinylive/webr, 매번 변동은 의도). §3.10 시드 항목 사실상 해소.

---

## P2 — 중기 (견고성·포용성·안전)

### 6. 업로드 입력 가드 (§3.11)
- [ ] 8개 CSV 업로드 앱에 공통 가드: 파일 크기 제한, 열 수/인코딩/타입 검증, 오류 메시지 처리.
- [ ] "개인정보 업로드 금지" 안내 문구 추가.

### 7. 접근성 (§3.12)
- [ ] 썸네일/그림에 `image-alt`/`fig-alt` 대체텍스트 추가.
- [ ] shinylive `viewerWidth: 800` 고정폭 → 반응형 확인/조정.
- [ ] `styles.css` 하드코딩 `blue` → CSS 변수·테마·색 대비(WCAG)·다크모드 대응.

### 8. 저장소 이전 (§3.3)
- [ ] iCloud Drive 밖(예: `~/dev/BitStat2`)으로 이전 → `.git` 손상·동기화 충돌 위험 제거.
- [ ] 필요 시 `docs/` 산출물을 소스 브랜치에서 분리(CI가 `gh-pages`로 배포).

---

## P3 — 성능·정돈

### 9. 패키지 슬림화 (§3.8)
- [ ] `library(tidyverse)`(2개 앱) → 실제 사용 하위 패키지만 로드.
- [ ] shinylive 초기 로딩 시간·다운로드 용량 측정·비교.

### 10. 설정 정리 (§3.9)
- [x] **`webr.packages` 커버리지 실측 완료**: `{webr-r}` 셀이 `library()`하는 패키지 중 **10개 누락**(BSDA·GGally·RColorBrewer·broom·moments·palmerpenguins·purrr·tidytext·vcd·wordcloud2) — 모두 webR 저장소(repo.r-wasm.org, R4.5)에 **바이너리 존재**함을 확인.
- [ ] (미적용·의도적 보류) 전역 `webr.packages`에 일괄 추가 시 **모든 페이지 시작 로딩 급증**(§3.8 부작용). 확장은 전역 목록을 매 페이지 설치(자동 per-library 설치 아님). → **페이지별 YAML `webr: packages:` 지정**이 올바른 해법. 런타임 Run-Code 검증 병행 필요.
- [x] `pyodide` 주석 필터 정리(제거).

---

## 렌더 엔진 문제 해결 (2026-07-05 완료)
- **증상**: 프리뷰/렌더 시 일부 페이지가 "Quarto Render Error"(`ModuleNotFound: No module named 'yaml'` — jupyter 커널 기동 실패).
- **원인 1(엔진)**: shinylive-r/webr-r 셀만 있고 knitr `{r}` 셀이 없는 문서는 freeze 무효화 시 quarto가 **jupyter 엔진을 자동선택** → 이 환경의 python에 pyyaml 부재로 실패. `_quarto.yml`·`_metadata.yml`의 `engine:`은 엔진 **자동선택을 못 덮음**(문서 front matter/`--metadata`만 유효).
- **해결 1**: 23개 모듈 `index.qmd` front matter에 `engine: knitr` 추가 + `_quarto.yml` 전역 `engine: knitr`(랜딩 페이지용).
- **원인 2(freeze)**: `.quarto` 중간 캐시의 `site_libs/quarto-contrib/shinylive` 부분 손상 → `utime: No such file` / `Directory not empty`.
- **해결 2**: `.quarto` 캐시 삭제 후 재렌더 → shinylive site_libs 재생성.
- **검증**: `quarto render` 전체 39개 파일 **오류 0건 성공**. dist_discrete 등 프리뷰 정상(WEBR Ready, 한글 렌더). 
- **주의**: `docs/`가 iCloud 경로라 `.quarto`/freeze 손상이 재발할 수 있음(§3.3 저장소 이전 권장).

## 검증 게이트 (모든 PR 공통 체크리스트)
- [ ] 공통 폰트 헬퍼 사용(한글 라벨 렌더 확인)
- [ ] 정본(인라인 블록) 위치 준수, 사본 미방치
- [ ] 썸네일·메타 필수값(`title`/`date`/`categories`/`image`)
- [ ] 업로드 앱이면 입력 가드 포함
- [ ] `quarto render` 성공(CI 통과)
