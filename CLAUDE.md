# CLAUDE.md

이 파일은 Claude Code가 이 저장소에서 작업할 때 참고하는 프로젝트 가이드다.

## 프로젝트 개요

- **이름**: 빛스탯2 (BitStat2) — 오픈 통계 학습 웹사이트
- **성격**: 통계 비전공자·일반인을 위한 인터랙티브 통계 교육 콘텐츠
- **기술 스택**: [Quarto](https://quarto.org) `website` + [shinylive](https://quarto-ext.github.io/shinylive/)(브라우저 WASM에서 Shiny 실행) + [webr](https://docs.r-wasm.org/webr/)
- **배포**: `quarto render` → `docs/` → GitHub Pages (https://r2bit.com/BitStat2/)
- **언어**: 한국어(`lang: ko-KR`)

## 디렉터리 구조

```
index.qmd             # 홈(랜딩 그리드), listing contents는 pages/NN_topic
pages/                # 랜딩 페이지 + 콘텐츠 모듈 (사이트 본문 전체)
  NN_topic.qmd        #   주제별 리스팅 랜딩, listing contents는 "NN_topic/*/index.qmd"
  NN_topic/           #   주제 폴더(콘텐츠)
    _metadata.yml     #     freeze: true, title-block-banner
    module/index.qmd  #     ★ 콘텐츠 + 인라인 shinylive 앱 (유일 정본)
    module/thumbnail.png
  about.qmd · BitStat.qmd
documents/            # 프로젝트 문서 — 사이트 렌더 제외(_quarto.yml render allowlist)
  PLAN.md · PROGRESS.md · CONTRIBUTING.md · LICENSE-content.md · DATA_LICENSES.md
  tech_document/      #   기술검토·보안 보고서
_quarto.yml           # 사이트 설정 (navbar, render allowlist=index+pages/, webr 패키지, 필터)
docs/                 # 빌드 산출물 (git 커밋됨, 직접 수정 금지)
_freeze/              # freeze 캐시 (git 커밋됨)
data/                 # 예제 데이터 (Galton, k_penguins 등)
images/               # 로고·썸네일·아키텍처 SVG
README.md · CLAUDE.md · LICENSE   # 루트 유지(관례)
```

> 2026-07-05: 랜딩 페이지와 **콘텐츠 폴더(`01_data`~`07_theory`)를 모두 `pages/` 아래로 이동**. 사이트 본문은 전부 `pages/`에 있고 `_quarto.yml`의 `render:`는 `index.qmd` + `pages/`만 나열. **URL 변경**: 랜딩 `/pages/NN_topic.html`, 모듈 `/pages/NN_topic/module/`(기존 `/NN_topic/module/`에서 변경). 신규 모듈은 `pages/NN_topic/` 아래에 추가.

## 핵심 컨벤션 (반드시 지킬 것)

### 1. Shiny 앱의 정본은 `index.qmd`의 인라인 `{shinylive-r}` 블록이다 (유일 정본)
- 실제 배포되는 것은 `index.qmd` 내 `{shinylive-r}` (`standalone: true`) 블록이다.
- 과거 존재하던 `shiny/app.R` 개발용 사본은 인라인 블록과 어긋난 stale 상태(drift 8/23)여서 **2026-07-05에 전부 삭제**했다(§3.1 정본화 완료). 이제 각 모듈 앱의 소스는 `index.qmd` 인라인 블록 **하나뿐**이다.
- **앱을 수정할 때는 `index.qmd`의 인라인 블록을 고칠 것.** `shiny/` 폴더는 더 이상 만들지 말 것.
- 상세 근거: [tech_document/2026-07-05_기술검토.md](documents/tech_document/2026-07-05_기술검토.md) §3.1

### 2. 한글 폰트 처리
- shinylive/webr(WASM)에서 한글 라벨이 깨지지 않도록 각 인라인 앱은 표준 폰트 스니펫을 사용한다:
  ```r
  library(showtext)
  showtext_auto()
  ```
- **금지**: `family = "Tahoma"` 등 Windows 전용/WASM 부재 폰트 지정(한글 미표시).
- 폰트 관련 상세: 기술검토 §3.2

### 3. 신규 모듈 추가 시
- `pages/NN_topic/module_name/index.qmd` 생성, YAML에 `title`/`author`/`date: today`/`image: thumbnail.png`/`categories` 필수.
- **YAML에 `engine: knitr` 필수** — shinylive-r/webr-r 셀만 있고 knitr `{r}` 셀이 없으면 quarto가 jupyter 엔진을 골라 렌더가 실패한다(§ 빌드 참조). 전역 `_quarto.yml`에도 `engine: knitr`가 있으나, 엔진 자동선택은 **문서 front matter**에서 확정해야 안전하다.
- 인라인 `{shinylive-r}` 블록으로 앱 작성(위 폰트 스니펫 포함).
- `thumbnail.png` 추가(리스팅 그리드용).

### 4. 재현성
- 정적으로 렌더되는 랜덤 예제 코드에는 `set.seed()`를 넣는다.
- 외부 URL 데이터는 가능하면 `data/`에 스냅샷으로 두고 참조한다.

## 빌드 / 개발 명령

```bash
quarto preview          # 로컬 미리보기 (port 7771)
quarto render           # 전체 렌더 → docs/
quarto render pages/04_testing/x_score/index.qmd   # 단일 파일 렌더
```

- Quarto 1.10+, R 필요. 필터: `shinylive`, `webr`(`_extensions/`에 번들됨).
- `freeze: true`이므로 코드 변경이 없으면 재계산하지 않는다. 강제 재계산은 `_freeze/` 해당 항목 삭제 후 렌더.
- **shinylive 자산 버전 고정(중요)**: 프로젝트 루트 `_environment` 파일에 `SHINYLIVE_ASSETS_VERSION=0.2.3`을 둔다. 이 없이 렌더하면 현재 R `shinylive` 패키지(0.3.0.9000)가 자산 **0.9.1**을 써서 앱이 `there is no package called 'munsell'`(ggplot2 로드 실패)로 **깨진다**. 0.2.3은 검증된 정상 버전(런타임 패키지 다운로드 방식). `_environment`는 quarto가 렌더 시 자동 적용(.Renviron은 확장 서브프로세스가 안 읽어 무효).
- **엔진**: 모든 콘텐츠 문서는 `engine: knitr`를 지정한다. 없으면 quarto가 jupyter 엔진을 골라 `ModuleNotFoundError: No module named 'yaml'`로 "Quarto Render Error"가 난다.
- **렌더 오류 시**: `.quarto` 중간 캐시가 손상되면(`utime: No such file`/`Directory not empty`, 특히 iCloud 경로) `rm -rf .quarto` 후 재렌더한다.

## 주의사항

- `docs/`는 빌드 산출물이다. 직접 편집하지 말고 소스(`*.qmd`)를 고친 뒤 렌더한다.
- 이 저장소는 현재 iCloud Drive 경로에 있다(`.git` 손상·동기화 충돌 위험). 대량 작업 전 백업 권장.
- 개선 작업은 [PLAN.md](documents/PLAN.md)의 우선순위(P0→P3)를 따르고, 완료 시 [PROGRESS.md](documents/PROGRESS.md)에 기록한다.
