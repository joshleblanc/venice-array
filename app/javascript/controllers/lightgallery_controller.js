import { Controller } from "@hotwired/stimulus"
import lightGallery from "lightgallery"

// Connects to data-controller="lightgallery"
export default class extends Controller {
  static targets = ["gallery"]

  connect() {
    console.log('LightGallery controller connected', lightGallery)
    this.initializeLightGallery()
    this.setupTurboListeners()
    
    // Make controller accessible for debugging
    window.lightGalleryController = this
  }

  disconnect() {
    console.log('LightGallery controller disconnected')
    this.destroyLightGallery()
    this.removeTurboListeners()
    
    // Clear any pending timeouts
    if (this.reinitializeTimeout) {
      clearTimeout(this.reinitializeTimeout)
    }
  }

  initializeLightGallery() {
    // Destroy existing instance if it exists
    // this.destroyLightGallery()

    // Find all image links in the gallery
    const imageLinks = this.element.querySelectorAll('.lightgallery-item')
    
    this.lightGalleryInstance = lightGallery(this.element, {
        plugins: [],
        selector: '.lightgallery-item',
        download: true,
        counter: true,
        getCaptionFromTitleOrAlt: true,
      })

      console.log(`LightGallery initialized with ${imageLinks.length} images`)
  }

  destroyLightGallery() {
    if (this.lightGalleryInstance) {
      try {
        this.lightGalleryInstance.destroy()
        console.log('LightGallery destroyed')
      } catch (error) {
        console.warn('Error destroying LightGallery:', error)
      } finally {
        this.lightGalleryInstance = null
      }
    }
    
    // Clean up any remaining lightgallery elements
    const lgElements = this.element.querySelectorAll('.lg-backdrop, .lg-outer')
    lgElements.forEach(el => {
      try {
        el.remove()
      } catch (error) {
        console.warn('Error removing LightGallery element:', error)
      }
    })
  }

  setupTurboListeners() {
    // Also listen for general DOM changes
    this.mutationObserver = new MutationObserver(this.handleMutation.bind(this))
    this.mutationObserver.observe(this.element, {
      childList: true,
      subtree: true,
      attributes: true,
      attributeFilter: ['data-src', 'href', 'class']
    })
    
    this.lastImageCount = this.element.querySelectorAll('.lightgallery-item').length
  }

  removeTurboListeners() {
     
    if (this.mutationObserver) {
      this.mutationObserver.disconnect()
    }
  
  }

  handleMutation(mutations) {
    let shouldReinitialize = false

    mutations.forEach(mutation => {
      // Check if new image links were added
      if (mutation.type === 'childList') {
        mutation.addedNodes.forEach(node => {
          if (node.nodeType === Node.ELEMENT_NODE) {
            const hasImageLinks = node.matches('.lightgallery-item') || 
                                 node.querySelector('.lightgallery-item')
            if (hasImageLinks) {
              shouldReinitialize = true
            }
          }
        })
      }
      
      // Check if href attributes changed (loading -> actual image)
      if (mutation.type === 'attributes' && 
          (mutation.attributeName === 'href' || mutation.attributeName === 'data-src')) {
        const target = mutation.target
        if (target.matches('.lightgallery-item') || target.closest('.lightgallery-item')) {
          shouldReinitialize = true
        }
      }
    })

    if (shouldReinitialize) {
      console.log('DOM mutation detected, reinitializing LightGallery')
      // Debounce reinitalization
      clearTimeout(this.reinitializeTimeout)
      this.reinitializeTimeout = setTimeout(() => {
        this.refresh()
      }, 200)
    }
  }

  // Manual refresh method that can be called from outside
  refresh() {
    console.log('Manual LightGallery refresh requested')
    this.lightGalleryInstance.refresh()
  }

  // Force cleanup and reinitialize (for debugging)
  reset() {
    console.log('Force reset LightGallery')
    this.destroyLightGallery()
    
    // Wait a bit before reinitializing
    setTimeout(() => {
      this.initializeLightGallery()
    }, 300)
  }

  // Check if gallery is in a healthy state
  healthCheck() {
    const imageLinks = this.element.querySelectorAll('.lightgallery-item')
    const hasInstance = !!this.lightGalleryInstance
    
    console.log(`LightGallery Health Check:`)
    console.log(`- Image links found: ${imageLinks.length}`)
    console.log(`- Instance exists: ${hasInstance}`)
    console.log(`- Element exists: ${!!this.element}`)
    
    return {
      imageCount: imageLinks.length,
      hasInstance,
      hasElement: !!this.element
    }
  }
}