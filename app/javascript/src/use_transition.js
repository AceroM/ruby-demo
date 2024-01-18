import { isEmpty } from "src/utils"

const alpineNames = {
  enterFromClass: "enter",
  enterActiveClass: "enterStart",
  enterToClass: "enterEnd",
  leaveFromClass: "leave",
  leaveActiveClass: "leaveStart",
  leaveToClass: "leaveEnd"
}

const defaultOptions = {
  transitioned: false,
  hiddenClass: "hidden",
  preserveOriginalClass: true,
  removeToClasses: true
}

export function useTransition(controller, options) {
  const targetName = controller.element.dataset.transitionTarget
  let targetFromAttribute
  if (targetName) {
    targetFromAttribute = controller[`${targetName}Target`]
  }
  const targetElement = options?.element || targetFromAttribute || controller.element
  // data attributes are only available on HTMLElement and SVGElement
  if (!(targetElement instanceof HTMLElement || targetElement instanceof SVGElement)) return

  const dataset = targetElement.dataset
  const leaveAfter = parseInt(dataset.leaveAfter || "") || options.leaveAfter || 0

  const { transitioned, hiddenClass, preserveOriginalClass, removeToClasses } = Object.assign(
    {},
    defaultOptions,
    options
  )

  const controllerEnter = controller.enter?.bind(controller)
  const controllerLeave = controller.leave?.bind(controller)
  const controllerToggleTransition = controller.toggleTransition?.bind(controller)

  async function enter(event) {
    if (controller.transitioned) return

    controller.transitioned = true
    controllerEnter && controllerEnter(event)

    const enterFromClasses = getAttribute("enterFrom", options, dataset)
    const enterActiveClasses = getAttribute("enterActive", options, dataset)
    const enterToClasses = getAttribute("enterTo", options, dataset)
    const leaveToClasses = getAttribute("leaveTo", options, dataset)

    if (!!hiddenClass) {
      targetElement.classList.remove(hiddenClass)
    }

    if (!removeToClasses) {
      removeClasses(targetElement, leaveToClasses)
    }
    await transition(
      targetElement,
      enterFromClasses,
      enterActiveClasses,
      enterToClasses,
      hiddenClass,
      preserveOriginalClass,
      removeToClasses
    )

    if (leaveAfter > 0) {
      setTimeout(() => {
        leave(event)
      }, leaveAfter)
    }
  }

  async function leave(event) {
    if (!controller.transitioned) return
    controller.transitioned = false
    controllerLeave && controllerLeave(event)

    const leaveFromClasses = getAttribute("leaveFrom", options, dataset)
    const leaveActiveClasses = getAttribute("leaveActive", options, dataset)
    const leaveToClasses = getAttribute("leaveTo", options, dataset)
    const enterToClasses = getAttribute("enterTo", options, dataset)

    if (!removeToClasses) {
      removeClasses(targetElement, enterToClasses)
    }

    await transition(
      targetElement,
      leaveFromClasses,
      leaveActiveClasses,
      leaveToClasses,
      hiddenClass,
      preserveOriginalClass,
      removeToClasses
    )

    if (!!hiddenClass) {
      targetElement.classList.add(hiddenClass)
    }
  }

  function toggleTransition(event) {
    controllerToggleTransition && controllerToggleTransition(event)

    if (controller.transitioned) {
      leave()
    } else {
      enter()
    }
  }

  async function transition(
    element,
    initialClasses,
    activeClasses,
    endClasses,
    hiddenClass,
    preserveOriginalClass,
    removeEndClasses,
  ) {
    // if there's any overlap between the current set of classes and initialClasses/activeClasses/endClasses,
    // we should remove them before we start and add them back at the end
    const stashedClasses = []
    if (preserveOriginalClass) {
      initialClasses.forEach(cls => element.classList.contains(cls) && cls !== hiddenClass && stashedClasses.push(cls))
      activeClasses.forEach(cls => element.classList.contains(cls) && cls !== hiddenClass && stashedClasses.push(cls))
      endClasses.forEach(cls => element.classList.contains(cls) && cls !== hiddenClass && stashedClasses.push(cls))
    }

    // Add initial class before element start transition
    addClasses(element, initialClasses)

    // remove the overlapping classes
    removeClasses(element, stashedClasses)

    // Add active class before element start transition and maitain it during the entire transition.
    addClasses(element, activeClasses)
    await nextAnimationFrame()

    // remove the initial class on frame after the beginning of the transition
    removeClasses(element, initialClasses)

    // add the endClass on frame after the beginning of the transition
    addClasses(element, endClasses)

    // dynamically comput the duration of the transition from the style of the element
    await afterTransition(element)

    // remove both activeClasses and endClasses
    removeClasses(element, activeClasses)
    if (removeEndClasses) {
      removeClasses(element, endClasses)
    }

    // restore the overlaping classes
    addClasses(element, stashedClasses)
  }

  function initialState() {
    controller.transitioned = transitioned
    if (transitioned) {
      if (!!hiddenClass) {
        targetElement.classList.remove(hiddenClass)
      }
      enter()
    } else {
      if (!!hiddenClass) {
        targetElement.classList.add(hiddenClass)
      }
      leave()
    }
  }

  function addClasses(element, classes) {
    if (classes.length > 0) {
      element.classList.add(...classes)
    }
  }

  function removeClasses(element, classes) {
    if (classes.length > 0) {
      element.classList.remove(...classes)
    }
  }

  initialState()
  Object.assign(controller, { enter, leave, toggleTransition })
  return [enter, leave, toggleTransition]
}

function getAttribute(name, options, dataset) {
  const datasetName = `transition${name[0].toUpperCase()}${name.slice(1)}`
  const datasetAlpineName = alpineNames[name]
  const classes = options[name] || dataset[datasetName] || dataset[datasetAlpineName] || " "
  return isEmpty(classes) ? [] : classes.split(" ")
}

async function afterTransition(element) {
  return new Promise(resolve => {
    const duration = Number(getComputedStyle(element).transitionDuration.split(",")[0].replace("s", "")) * 1000
    setTimeout(() => {
      resolve(duration)
    }, duration)
  })
}


async function nextAnimationFrame() {
  return new Promise(resolve => {
    requestAnimationFrame(() => {
      requestAnimationFrame(resolve)
    })
  })
}