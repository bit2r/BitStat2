# BitStat2 보안 조치 보고서 — polyfill.io 공급망 공격 제거

- **작성일**: 2026-07-05
- **대상**: `bit2r/BitStat2` 배포 산출물(`docs/`)
- **분류**: 🔴 공급망 공격(Supply-chain attack) / 악성 외부 스크립트 제거
- **상태**: ✅ 조치 완료

---

## 1. 요약

BitStat2 배포 HTML(`docs/`) 전반에 **`polyfill.io` CDN 스크립트**가 포함되어 있었다.

```html
<script src="https://polyfill.io/v3/polyfill.min.js?features=es6"></script>
```

`polyfill.io`는 2024년 발생한 **대규모 공급망 공격의 감염 벡터**로, 현재 도메인에서 로드되는
스크립트는 방문자에게 악성 코드(악성 리다이렉트·멀웨어)를 주입할 수 있다. 해당 스크립트를
**10개 HTML 파일에서 모두 제거**했다. 정상 의존성(MathJax, monaco-editor 등 jsDelivr CDN)은
영향이 없어 그대로 유지했다.

---

## 2. 배경 — polyfill.io 사건

- `polyfill.io`(및 `cdn.polyfill.io`)는 구형 브라우저에 최신 JS 기능을 보충(polyfill)해 주던
  인기 오픈소스 CDN 서비스였다.
- **2024년 2월** 도메인과 GitHub 저장소가 제3자(중국 소재 업체 Funnull)로 **매각**되었다.
- **2024년 6월** 이후 이 CDN이 특정 조건(모바일 기기 등)에서 **악성 스크립트를 주입**하는 것이
  다수 보안 연구진에 의해 확인되었다(악성 도메인으로의 리다이렉트 등). 10만 개 이상의
  웹사이트가 영향을 받은 것으로 보고되었다.
- 원저작자(Fastly, Cloudflare 등)는 즉시 **미러/대체 서비스**를 안내했고, 브라우저·호스팅
  업계는 `polyfill.io` 도메인 사용 중단을 권고했다. 원 개발자 역시 "**어떤 사이트도
  polyfill.io를 사용해서는 안 된다**"고 공지했다.
- 주요 도구 체인도 대응했다: **Quarto는 1.5 버전 즈음부터 기본 HTML 템플릿에서
  polyfill.io 삽입을 제거**했다.

> 결론: `polyfill.io`에서 로드되는 스크립트는 **신뢰할 수 없는 악성 코드**로 간주해야 하며,
> 즉시 제거 대상이다.

---

## 3. BitStat2에서의 발견

### 3.1 삽입 경로
- `polyfill.io` 스크립트는 **BitStat2 소스(`*.qmd`, `_quarto.yml`, `_extensions/` 등)에는 존재하지
  않는다.** 저장소 전수 검색 결과 소스 파일에서는 참조가 발견되지 않았다.
- 이 스크립트는 **약 3년 전 구버전 Quarto**가 문서에 수식(MathJax)이 있을 때 자동으로 넣던
  템플릿 조각으로, 당시 렌더된 `docs/` HTML에 그대로 **정적으로 박혀** 배포되고 있었다.
- 즉, 현재의 Quarto 1.10으로 재렌더하면 이 스크립트는 더 이상 추가되지 않지만, **과거에
  빌드되어 커밋된 `docs/` 산출물**에는 남아 있었다.

### 3.2 영향 범위(제거 전)
- `polyfill.io/v3/polyfill.min.js`를 로드하는 **HTML 10개 파일**:
  - 주제 랜딩: `docs/01_data.html`, `02_eda.html`, `03_viz.html`, `04_testing.html`,
    `05_infer.html`, `06_reg.html`, `07_theory.html`
  - 홈: `docs/index.html`
  - 모듈: `docs/04_testing/one_mean/index.html`, `docs/06_reg/reg/index.html`
- 공통적으로 **수식(MathJax)을 포함한 페이지**에 mathjax 스크립트와 짝지어 삽입되어 있었다.

### 3.3 오탐 배제(제거하지 않은 항목)
아래 "polyfill" 문자열은 악성 CDN과 **무관한 내부 구현**이므로 그대로 보존했다.
- `docs/site_libs/quarto-contrib/shinylive-*/shinylive/shinylive.js` 내부의
  `POLYFILL_EVENT_PLUGINS`, `InputEventPolyfill` 등 — React/브라우저 이벤트 처리용 자체 코드.
- `docs/site_libs/quarto-diagram/mermaid-init.js`의 `String.prototype.replaceAll() polyfill` —
  로컬 번들 내 자체 폴리필.

### 3.4 함께 점검한 외부 CDN(안전 — 유지)
| CDN | 용도 | 판정 |
|-----|------|------|
| `cdn.jsdelivr.net/npm/mathjax@3/...` | 수식 렌더(MathJax) | 신뢰 CDN, 유지 |
| `cdn.jsdelivr.net/npm/monaco-editor@0.47.0/...` | webr 코드 에디터 | 신뢰 CDN, 유지 |

jsDelivr은 평판 있는 공용 CDN으로 이번 사건과 무관하다.

---

## 4. 조치 내용

- **`polyfill.io` 스크립트 라인을 10개 HTML 파일에서 전부 삭제**했다(해당 `<script>` 한 줄만
  제거, 다른 마크업·MathJax 로더는 보존).
- 제거 후 재검증: 저장소 HTML/소스에서 `polyfill.io` 악성 CDN 참조 **0건**.
- 기능 영향: 없음. 이 폴리필은 ES6 미지원의 **매우 구형 브라우저**만을 위한 것으로, 현재
  지원 브라우저와 MathJax 3 동작에는 불필요하다.

### 재발 방지
- 소스에 참조가 없고 현재 Quarto(1.10)는 polyfill.io를 삽입하지 않으므로, **정상 재렌더 시
  다시 추가되지 않는다.**
- 향후 `docs/` 커밋 전 점검 권장:
  ```bash
  grep -rl "polyfill.io" docs/ --include="*.html"   # 결과가 없어야 함
  ```
- 중기적으로 외부 CDN 의존을 줄이려면 MathJax/monaco도 로컬 번들(자체 호스팅)로 전환을 검토.

---

## 5. 검증 명령(재현)

```bash
# 1) 악성 CDN 잔존 여부 (0이어야 정상)
grep -rc "polyfill.io/v3/polyfill.min.js" docs/ --include="*.html" | grep -v ':0'

# 2) 정상 의존성(MathJax)은 유지되었는지
grep -rc "mathjax@3" docs/ --include="*.html" | grep -v ':0'
```

---

## 6. 참고

- Quarto의 polyfill.io 제거: 배포 템플릿에서 삭제됨(1.5 계열).
- 권고: `polyfill.io`를 참조하는 모든 프로젝트는 즉시 제거하거나 Fastly/Cloudflare의 안전한
  미러로 교체할 것.
