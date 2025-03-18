"use client"

import React, { useState, type ReactNode } from "react"
import { cn } from "@/lib/utils"

interface TabsProps {
  defaultValue: string
  className?: string
  children: ReactNode
}

interface TabsListProps {
  className?: string
  children: ReactNode
}

interface TabsTriggerProps {
  value: string
  className?: string
  children: ReactNode
}

interface TabsContentProps {
  value: string
  className?: string
  children: ReactNode
}

export const Tabs = ({ defaultValue, className, children }: TabsProps) => {
  const [activeTab, setActiveTab] = useState(defaultValue)

  return (
    <TabsContext.Provider value={{ activeTab, setActiveTab }}>
      <div className={cn("w-full", className)}>{children}</div>
    </TabsContext.Provider>
  )
}

const TabsContext = React.createContext<
  | {
      activeTab: string
      setActiveTab: (value: string) => void
    }
  | undefined
>(undefined)

export const useTabsContext = () => {
  const context = React.useContext(TabsContext)
  if (!context) {
    throw new Error("Tabs components must be used within a Tabs component")
  }
  return context
}

export const TabsList = ({ className, children }: TabsListProps) => {
  return (
    <div
      className={cn("inline-flex h-10 items-center justify-center rounded-md bg-gray-100 p-1 text-gray-500", className)}
    >
      {children}
    </div>
  )
}

export const TabsTrigger = ({ value, className, children }: TabsTriggerProps) => {
  const { activeTab, setActiveTab } = useTabsContext()
  const isActive = activeTab === value

  return (
    <button
      type="button"
      onClick={() => setActiveTab(value)}
      className={cn(
        "inline-flex items-center justify-center whitespace-nowrap rounded-sm px-3 py-1.5 text-sm font-medium transition-all",
        isActive ? "bg-white text-blue-700 shadow-sm" : "hover:bg-gray-200 hover:text-gray-700",
        className,
      )}
    >
      {children}
    </button>
  )
}

export const TabsContent = ({ value, className, children }: TabsContentProps) => {
  const { activeTab } = useTabsContext()
  if (activeTab !== value) return null

  return <div className={cn("mt-2", className)}>{children}</div>
}

