# 빛스탯2 (BitStat2)

> 통계 비전공자·일반인을 위한 **오픈 통계 학습 웹사이트**

[![site](https://img.shields.io/badge/site-r2bit.com%2FBitStat2-blue)](https://r2bit.com/BitStat2/)

빛스탯2는 브라우저에서 바로 실행되는 인터랙티브 통계 교육 콘텐츠입니다. 서버 없이
[shinylive](https://quarto-ext.github.io/shinylive/)/[webR](https://docs.r-wasm.org/webr/)
로 Shiny 앱과 R 코드를 **브라우저(WASM)** 에서 직접 실행하므로, 별도 설치 없이 통계를
"만지면서" 배울 수 있습니다.

- **사이트**: <https://r2bit.com/BitStat2/>
- **소개**: 코로나19로 심화된 디지털 불평등 해소와 데이터 리터러시 강화를 위한 오픈 통계 패키지 '빛스탯' 프로젝트의 학습 사이트입니다.
- **언어**: 한국어 (`lang: ko-KR`)

## 기술 스택

| 요소 | 사용 도구 |
|------|-----------|
| 사이트 빌드 | [Quarto](https://quarto.org) `website` 프로젝트 (1.10+) |
| 인터랙티브 앱 | `shinylive` 필터 — 브라우저 WASM에서 Shiny 실행 |
| 코드 실행 셀 | `webr` 필터 — 브라우저에서 R 코드 실행 |
| 배포 | `quarto render` → `docs/` → GitHub Pages |
| 테마 | `spacelab` |

## 콘텐츠 구성

7개 대주제 아래 23개 학습 모듈로 통계 교육과정 전반을 포괄합니다.

| 주제 | 폴더 | 예시 모듈 |
|------|------|-----------|
| 01 데이터 | `01_data/` | 연속/이산 분포, 분포 적합, 표집 방법 |
| 02 EDA | `02_eda/` | 기술통계, 일변량/다변량, 워드클라우드 |
| 03 시각화 | `03_viz/` | esquisse, 시각화 |
| 04 통계검정 | `04_testing/` | 일표본/이표본 평균·비율, 표준점수 |
| 05 추론 | `05_infer/` | 신뢰구간, 중심극한정리 |
| 06 회귀분석 | `06_reg/` | 상관·회귀, 회귀 |
| 07 통계이론 | `07_theory/` | 대수의 법칙, MLE, 군집화, 표본크기 |

## 디렉터리 구조

```
index.qmd             # 홈(랜딩 그리드)
pages/                # 랜딩 페이지 + 콘텐츠 모듈 (사이트 본문 전체)
  NN_topic.qmd        #   주제별 리스팅 랜딩 (01_data ~ 07_theory)
  NN_topic/           #   주제 폴더(콘텐츠)
    _metadata.yml     #     freeze: true, title-block-banner
    module/
      index.qmd       #     ★ 콘텐츠 + 인라인 shinylive 앱 (유일 정본)
      thumbnail.png   #     리스팅 그리드 썸네일
  about.qmd · BitStat.qmd
documents/            # 프로젝트 문서 (사이트 렌더 제외)
  PLAN.md · PROGRESS.md · CONTRIBUTING.md
  LICENSE-content.md · DATA_LICENSES.md
  tech_document/      #   기술검토·보안 보고서
_quarto.yml           # 사이트 설정 (navbar, render, webr 패키지, 필터)
docs/                 # 빌드 산출물 (GitHub Pages, 직접 수정 금지)
_freeze/              # freeze 캐시
data/                 # 예제 데이터 (Galton, k_penguins 등)
images/               # 로고·썸네일·아키텍처 SVG
README.md · CLAUDE.md · LICENSE   # 루트 유지(관례)
```

## 로컬 개발

전제: **Quarto 1.10+**, **R 4.x**. shinylive·webr 필터는 `_extensions/`에 번들되어 있습니다.

```bash
quarto preview          # 로컬 미리보기 (http://localhost:7771)
quarto render           # 전체 렌더 → docs/
quarto render pages/04_testing/x_score/index.qmd   # 단일 파일 렌더
```

- `freeze: true`이므로 코드 변경이 없으면 재계산하지 않습니다. 강제 재계산은 해당 `_freeze/` 항목을 삭제한 뒤 렌더합니다.
- 배포 흐름: 소스(`*.qmd`) 수정 → `quarto render` → `docs/` 커밋 → GitHub Pages 갱신.

## 핵심 컨벤션

기여 규칙과 PR 체크리스트는 [CONTRIBUTING.md](documents/CONTRIBUTING.md)를, 저장소 작업 가이드는
[CLAUDE.md](CLAUDE.md)를 참고하세요. 요약하면:

1. **Shiny 앱의 정본은 `index.qmd`의 인라인 `{shinylive-r}` 블록입니다(유일 정본).** 과거의
   `shiny/app.R` 사본은 stale 상태여서 모두 삭제했습니다. 앱 수정 시 인라인 블록을 고치세요.
2. **한글 폰트**: 한글 라벨을 그리는 앱/코드셀은 `library(showtext); showtext_auto()`를 포함합니다.
   `family = "Tahoma"` 등 WASM에 없는 Windows 전용 폰트는 사용하지 않습니다.
3. **신규 모듈**: `pages/NN_topic/module/index.qmd` 생성 + YAML 필수값(`title`/`author`/`date`/`image`/`categories`) + `thumbnail.png`.
4. **재현성**: 정적 렌더 랜덤 예제에는 `set.seed()`, 외부 URL 데이터는 `data/` 스냅샷 참조.

## 라이선스

이 저장소는 대상별로 라이선스를 분리합니다.

- **소스 코드**(R/Shiny/빌드 스크립트): [GPL-3.0](LICENSE)
- **학습 콘텐츠**(문서·글·그림): [CC BY-NC-SA 4.0](documents/LICENSE-content.md)
- **예제 데이터**: 각 파일별 출처·라이선스는 [DATA_LICENSES.md](documents/DATA_LICENSES.md) 참조

## 관련 링크

- 홈페이지: <https://r2bit.com>
- Seoul R Meetup: <https://r2bit.com/seoul-r>
- GitHub: <https://github.com/bit2r/BitStat2>
- Discord: <https://discord.gg/wJbu4WQz>
