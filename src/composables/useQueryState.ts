import { computed } from 'vue'
import { useRoute, useRouter } from 'vue-router'

/**
 * Two-way binds a URL query parameter, so filtered views are shareable and
 * survive reloads and back/forward navigation.
 */
export function useQueryState(key: string, fallback = '') {
  const route = useRoute()
  const router = useRouter()
  return computed<string>({
    get: () => {
      const v = route.query[key]
      return (Array.isArray(v) ? v[0] : v) ?? fallback
    },
    set: (value) => {
      const query = { ...route.query }
      if (!value || value === fallback) delete query[key]
      else query[key] = value
      router.replace({ query })
    },
  })
}
