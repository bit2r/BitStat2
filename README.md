# 빛스탯2 (BitStat2) — 포털

> 통계 비전공자·일반인을 위한 **오픈 통계 학습 플랫폼** — 만지며, 코딩하며 배웁니다.

[![site](https://img.shields.io/badge/site-r2bit.com%2FBitStat2-blue)](https://r2bit.com/BitStat2/)

빛스탯2는 같은 통계 커리큘럼(7개 챕터 · 23개 토픽)을 **두 가지 방식**으로 제공합니다.
모두 [webR](https://docs.r-wasm.org/webr/)(WebAssembly)로 **브라우저에서 직접 실행**되며 설치가 필요 없습니다.

| 트랙 | 저장소 | 배움의 방식 | 스택 |
|------|--------|-------------|------|
| **앱 트랙** — BitStat2 앱 | [bit2r/bitstat2-shiny](https://github.com/bit2r/bitstat2-shiny) | 클릭·슬라이더로 **만지며 직관** | Shiny × shinylive × webR |
| **코드 트랙** — BitStat2 Live | [bit2r/BitStat2-quarto](https://github.com/bit2r/BitStat2-quarto) | 편집형 R 셀·자동 채점으로 **코딩하며 원리** ([사이트](https://r2bit.com/BitStat2-quarto/)) | Quarto Live × webR |

**이 저장소(BitStat2)는 포털**입니다 — 랜딩 페이지와 프로젝트 조율(커리큘럼 설계 · 공통 문서 · 라이선스)의
정본을 갖고, 학습 콘텐츠의 정본은 각 트랙 저장소에 있습니다. (2026-07-06 모노레포 분리)

## 커리큘럼

01 데이터 · 02 탐색적 데이터 분석 · 03 시각화 · 04 통계 검정 · 05 추론 · 06 회귀분석 · 07 통계이론 — 23개 토픽.

## 빌드

```bash
quarto render   # index.qmd 한 페이지 → docs/
```

## 라이선스

- **콘텐츠**: CC BY-NC-SA 4.0 ([documents/LICENSE-content.md](documents/LICENSE-content.md))
- **코드**: GPL-3.0 ([LICENSE](LICENSE))
- **데이터**: [documents/DATA_LICENSES.md](documents/DATA_LICENSES.md)

한국 R 사용자회([bit2r](https://github.com/bit2r))가 만듭니다.
