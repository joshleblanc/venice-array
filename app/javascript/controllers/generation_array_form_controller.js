import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "styleCheckbox",
    "randomButton",
    "randomButtonText",
    "modelSelect",
    "stepsInput",
    "estimatedImages",
    "estimatedPerImage",
    "estimatedTotal"
  ]

  static values = {
    modelCosts: Object,
    totalStyles: Number
  }

  connect() {
    this.currentRandomConfig = 0

    this.popularStyles = [
      "Photographic",
      "Digital Art",
      "Anime",
      "Cinematic",
      "Fantasy Art",
      "Abstract",
      "Watercolor",
      "Oil Painting"
    ]

    this.randomConfigs = [
      { count: 5, label: "5 Random" },
      { count: 8, label: "8 Random" },
      { count: 12, label: "12 Random" },
      { count: 15, label: "15 Random" }
    ]

    this.updateRandomButtonText()
    this.updateEstimatedCost()
  }

  selectAllStyles() {
    this.styleCheckboxTargets.forEach((checkbox) => {
      checkbox.checked = true
    })
    this.updateRandomButtonText()
    this.updateEstimatedCost()
  }

  deselectAllStyles() {
    this.styleCheckboxTargets.forEach((checkbox) => {
      checkbox.checked = false
      const label = checkbox.closest("label")
      if (label) label.classList.remove("style-checkbox-highlight")
    })
    this.updateRandomButtonText()
    this.updateEstimatedCost()
  }

  selectPopularStyles() {
    this.styleCheckboxTargets.forEach((checkbox) => {
      checkbox.checked = this.popularStyles.includes(checkbox.value)
      const label = checkbox.closest("label")
      if (label) label.classList.remove("style-checkbox-highlight")
    })
    this.updateRandomButtonText()
    this.updateEstimatedCost()
  }

  selectRandomStyles() {
    const checkboxes = [...this.styleCheckboxTargets]
    const config = this.randomConfigs[this.currentRandomConfig]

    // Clear all selections first with animation
    checkboxes.forEach((checkbox) => {
      checkbox.checked = false
      const label = checkbox.closest("label")
      if (label) label.classList.remove("style-checkbox-highlight")
    })

    this.updateEstimatedCost()

    // Shuffle array and select random styles
    const shuffled = checkboxes.sort(() => 0.5 - Math.random())
    const selectedCount = Math.min(config.count, checkboxes.length)

    // Add visual feedback during selection
    if (this.hasRandomButtonTarget) {
      this.randomButtonTarget.disabled = true
      this.randomButtonTarget.classList.add("random-button-loading")
    }

    if (this.hasRandomButtonTextTarget) {
      this.randomButtonTextTarget.textContent = "🎲 Selecting..."
    }

    let selectedSoFar = 0
    const selectionInterval = setInterval(() => {
      if (selectedSoFar < selectedCount) {
        const checkbox = shuffled[selectedSoFar]
        const label = checkbox.closest("label")

        checkbox.checked = true
        if (label) label.classList.add("style-checkbox-highlight")

        setTimeout(() => {
          if (label) {
            label.scrollIntoView({
              behavior: "smooth",
              block: "nearest"
            })
          }
        }, 50)

        selectedSoFar++
        if (this.hasRandomButtonTextTarget) {
          this.randomButtonTextTarget.textContent = `🎲 Selected ${selectedSoFar}/${selectedCount}`
        }

        this.updateEstimatedCost()
      } else {
        clearInterval(selectionInterval)

        this.currentRandomConfig = (this.currentRandomConfig + 1) % this.randomConfigs.length

        setTimeout(() => {
          if (this.hasRandomButtonTarget) {
            this.randomButtonTarget.disabled = false
            this.randomButtonTarget.classList.remove("random-button-loading")
          }

          if (this.hasRandomButtonTextTarget) {
            this.randomButtonTextTarget.textContent = `✨ ${selectedCount} Styles Selected!`
          }

          if (this.hasRandomButtonTarget) {
            this.randomButtonTarget.classList.add("animate-pulse")
          }

          setTimeout(() => {
            if (this.hasRandomButtonTarget) {
              this.randomButtonTarget.classList.remove("animate-pulse")
            }
            this.updateRandomButtonText()
            this.updateEstimatedCost()
          }, 2000)
        }, 300)
      }
    }, 200)
  }

  styleChanged() {
    this.updateRandomButtonText()
    this.updateEstimatedCost()
  }

  updateRandomButtonText() {
    if (!this.hasRandomButtonTextTarget) return

    const config = this.randomConfigs[this.currentRandomConfig]
    const selectedCount = this.selectedStylesCount()

    if (selectedCount === 0) {
      this.randomButtonTextTarget.textContent = `Random ${config.count}`
    } else {
      this.randomButtonTextTarget.textContent = `Random ${config.count} (${selectedCount} selected)`
    }
  }

  updateEstimatedCost() {
    if (!this.hasEstimatedImagesTarget || !this.hasEstimatedPerImageTarget || !this.hasEstimatedTotalTarget) return

    const totalStyles = this.totalStylesValue || 0
    const selectedCount = this.selectedStylesCount()
    const imageCount = selectedCount === 0 ? totalStyles : selectedCount

    this.estimatedImagesTarget.textContent = imageCount > 0 ? String(imageCount) : "-"

    const modelId = this.hasModelSelectTarget ? this.modelSelectTarget.value : null
    const steps = this.hasStepsInputTarget ? parseFloat(this.stepsInputTarget.value || "0") : 0

    const md = modelId && this.modelCostsValue ? this.modelCostsValue[modelId] : null

    if (!md || (!md.USD && !md.DIEM)) {
      this.estimatedPerImageTarget.textContent = "-"
      this.estimatedTotalTarget.textContent = "-"
      return
    }

    const defaultSteps = parseFloat(md.default_steps || "0")
    const factor = defaultSteps > 0 ? steps / defaultSteps : 1.0

    const usdPer = md.USD != null ? parseFloat(md.USD) * factor : null
    const diemPer = md.DIEM != null ? parseFloat(md.DIEM) * factor : null

    const usdTotal = usdPer != null ? usdPer * imageCount : null
    const diemTotal = diemPer != null ? diemPer * imageCount : null

    const usdFmt = new Intl.NumberFormat("en-US", { style: "currency", currency: "USD" })

    const perParts = []
    if (usdPer != null && !Number.isNaN(usdPer)) perParts.push(usdFmt.format(usdPer))
    if (diemPer != null && !Number.isNaN(diemPer)) perParts.push(`${diemPer.toFixed(4)} DIEM`)

    const totalParts = []
    if (usdTotal != null && !Number.isNaN(usdTotal)) totalParts.push(usdFmt.format(usdTotal))
    if (diemTotal != null && !Number.isNaN(diemTotal)) totalParts.push(`${diemTotal.toFixed(4)} DIEM`)

    this.estimatedPerImageTarget.textContent = perParts.length ? perParts.join(" | ") : "-"
    this.estimatedTotalTarget.textContent = totalParts.length ? totalParts.join(" | ") : "-"
  }

  selectedStylesCount() {
    return this.styleCheckboxTargets.filter((cb) => cb.checked).length
  }
}
