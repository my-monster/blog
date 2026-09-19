<template>
  <div class="giscus-wrapper" id="vuepress-plugin-comment" v-if="showComment">
    <div v-if="!isConfigReady" class="giscus-pending-card">
      <p class="title">💬 Giscus 评论系统已就绪</p>
      <p class="desc">
        已绑定仓库 <code>{{ config.repo || 'my-monster/blog-comments' }}</code>。请前往 GitHub 开启 Discussions 并获取 <b>分类名 (Category)</b> 与 <b>分类 ID (Category ID)</b> 填入 <code>docs/.vuepress/config/giscus.ts</code> 即可开启评论互动！
      </p>
    </div>
    <div v-show="isConfigReady" ref="giscusContainer" class="giscus-container"></div>
  </div>
</template>

<script>
export default {
  name: 'Giscus',
  data() {
    return {
      observer: null
    }
  },
  computed: {
    config() {
      return this.$themeConfig.giscus || {}
    },
    showComment() {
      const { $frontmatter } = this
      return (
        $frontmatter.comment !== false &&
        $frontmatter.article !== false &&
        !$frontmatter.pageComponent
      )
    },
    isConfigReady() {
      return !!(this.config.category && this.config.categoryId)
    }
  },
  mounted() {
    if (this.showComment && this.isConfigReady) {
      this.loadGiscus()
    }
    this.observeTheme()
  },
  watch: {
    '$route.path'() {
      if (this.showComment && this.isConfigReady) {
        this.$nextTick(() => {
          this.loadGiscus()
        })
      }
    }
  },
  beforeDestroy() {
    if (this.observer) {
      this.observer.disconnect()
    }
  },
  methods: {
    getCurrentTheme() {
      if (typeof document === 'undefined') return 'light'
      const isDark = document.documentElement.classList.contains('theme-mode-dark')
      return isDark ? 'dark' : 'light'
    },
    loadGiscus() {
      const container = this.$refs.giscusContainer
      if (!container) return

      // 若已有 iframe，尝试通过 postMessage 更新页面路径
      const existingIframe = container.querySelector('iframe.giscus-frame')
      if (existingIframe) {
        existingIframe.contentWindow.postMessage(
          {
            giscus: {
              setConfig: {
                term: window.location.pathname
              }
            }
          },
          'https://giscus.app'
        )
        return
      }

      container.innerHTML = ''
      const script = document.createElement('script')
      script.src = 'https://giscus.app/client.js'
      script.setAttribute('data-repo', this.config.repo || 'my-monster/blog-comments')
      script.setAttribute('data-repo-id', this.config.repoId || 'R_kgDOUhamIw')
      script.setAttribute('data-category', this.config.category)
      script.setAttribute('data-category-id', this.config.categoryId)
      script.setAttribute('data-mapping', this.config.mapping || 'pathname')
      script.setAttribute('data-strict', this.config.strict || '0')
      script.setAttribute('data-reactions-enabled', this.config.reactionsEnabled || '1')
      script.setAttribute('data-emit-metadata', this.config.emitMetadata || '0')
      script.setAttribute('data-input-position', this.config.inputPosition || 'top')
      script.setAttribute('data-theme', this.getCurrentTheme())
      script.setAttribute('data-lang', this.config.lang || 'zh-CN')
      script.setAttribute('data-loading', this.config.loading || 'lazy')
      script.crossOrigin = 'anonymous'
      script.async = true

      container.appendChild(script)
    },
    observeTheme() {
      if (typeof window === 'undefined' || typeof MutationObserver === 'undefined') return
      this.observer = new MutationObserver(() => {
        const iframe = document.querySelector('iframe.giscus-frame')
        if (iframe) {
          iframe.contentWindow.postMessage(
            {
              giscus: {
                setConfig: {
                  theme: this.getCurrentTheme()
                }
              }
            },
            'https://giscus.app'
          )
        }
      })
      this.observer.observe(document.documentElement, {
        attributes: true,
        attributeFilter: ['class']
      })
    }
  }
}
</script>

<style scoped>
.giscus-wrapper {
  margin: 2rem 0 1rem;
  padding-top: 1rem;
}
.giscus-pending-card {
  border: 1px dashed var(--borderColor, #e2e8f0);
  border-radius: 8px;
  padding: 1.2rem 1.5rem;
  background: rgba(0, 0, 0, 0.02);
  margin-top: 1rem;
}
.giscus-pending-card .title {
  font-size: 1rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
  color: var(--textColor, #2c3e50);
}
.giscus-pending-card .desc {
  font-size: 0.9rem;
  color: #666;
  line-height: 1.6;
  margin: 0;
}
.giscus-pending-card code {
  background: rgba(0, 0, 0, 0.05);
  padding: 0.2rem 0.4rem;
  border-radius: 4px;
}
</style>
